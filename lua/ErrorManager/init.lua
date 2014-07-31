--[[   Copyright 2014 Sergej Nisin

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
]]
local ERRORMANAGER_PATH = ERRORMANAGER_PATH or ({...})[1]:gsub("[%.\\/]init$", ""):gsub("%.", "/")

local ErrorManager = {}

local oldprint = print
local printtable = {}
function print(...)
	local stringtable = {}
	for i,v in ipairs({...}) do
		stringtable[i] = tostring(v)
	end
	table.insert(printtable, table.concat(stringtable, "\t"))
	oldprint(...)
end

local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end
local function getTraceback(msg)
	msg = tostring(msg)

	error_printer(msg, 2)

	local trace = debug.traceback()
	local err = {}

	table.insert(err, "Error\n")
	table.insert(err, msg.."\n\n")

	local numl = 0
	for l in string.gmatch(trace, "(.-)\n") do
		numl = numl + 1
		if not string.match(l, "ErrorManager") and not string.match(l, "boot.lua") then
			l = string.gsub(l, "stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = string.gsub(p, "\t", "")
	p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

	return p
end


ErrorManager.trace = ""
local this = {}

function ErrorManager.load()
	this.scale = love.window.getPixelScale and love.window.getPixelScale() or 1
	this.font = love.graphics.setNewFont(math.floor(14*this.scale))
	this.bigfont = love.graphics.setNewFont(math.floor(30*this.scale))
	this.hugefont = love.graphics.setNewFont(math.floor(40*this.scale))
	this.eggimg = love.graphics.newImage("gfx/error.png")

	this.reportclicked = false
	this.sended = false
	this.senderror = false

	this.reportThread = nil
	this.reportChannel = nil
end
function ErrorManager.update()
	if this.reportThread and this.reportThread:getError( ) then 
		print(this.reportThread:getError()) 
		this.senderror = this.reportThread:getError()
	end

	if this.reportChannel then
		local value = this.reportChannel:pop()
		while value do
			if type(value) == "table" then
				if value.id == "content" then
					--self.content = value.value
				elseif value.id == "success" then
					this.sended = true
				elseif value.id == "error" then
					this.senderror = value.desc
					print("Error: ".. value.desc)
				end
			end

			value = this.reportChannel:pop()
		end
	end
end
function ErrorManager.draw()
	love.graphics.setColor(200, 0, 0)
	love.graphics.setFont(this.bigfont)
	local imgwidth = this.eggimg:getWidth() * this.scale
	love.graphics.printf("Oops, an error occurred", 30*this.scale, 40*this.scale, love.graphics.getWidth() - 20*this.scale - imgwidth)
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(this.eggimg, love.graphics.getWidth() - imgwidth, 10, 0, this.scale, this.scale)

	love.graphics.setFont(this.font)
	love.graphics.printf(ErrorManager.trace, 30, this.eggimg:getHeight() * this.scale + 30* this.scale, love.graphics.getWidth() - 60)

	--width, lines = Font:getWrap(text, width)


	local buttheight = 40*this.scale + this.hugefont:getHeight()  -- Report button
	local butty = love.graphics.getHeight() - buttheight - 1
	love.graphics.setColor(0, 200, 0)
	love.graphics.rectangle("fill", 1, butty, love.graphics.getWidth()-2, buttheight)
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("line", 1, butty, love.graphics.getWidth()-2, buttheight)
	if not this.reportclicked then
		love.graphics.setFont(this.hugefont)
		love.graphics.printf("Send report", 0, butty+20*this.scale, love.graphics.getWidth(), "center")
	else
		if this.senderror then
			love.graphics.setFont(this.bigfont)
			love.graphics.printf("Sending failed", 0, butty+20*this.scale, love.graphics.getWidth(), "center")
		elseif this.sended then
			love.graphics.setFont(this.hugefont)
			love.graphics.printf("Thank you", 0, butty+20*this.scale, love.graphics.getWidth(), "center")
		else
			love.graphics.setFont(this.hugefont)
			love.graphics.printf("Sending...", 0, butty+20*this.scale, love.graphics.getWidth(), "center")
		end
	end

	-- local butty = love.graphics.getHeight() - buttheight*2 - 1 -- Report button
	-- love.graphics.setColor(255, 255, 255)
	-- love.graphics.rectangle("fill", 1, butty, love.graphics.getWidth()-2, buttheight)
	-- love.graphics.setColor(0, 0, 0)
	-- love.graphics.rectangle("line", 1, butty, love.graphics.getWidth()-2, buttheight)
	-- love.graphics.printf("Send report", 0, butty+10*this.scale, love.graphics.getWidth(), "center")
	--love.graphics.printf(ErrorManager.trace, 30, 30, love.graphics.getWidth() - 60)
end
function ErrorManager.mousepressed(x, y, button)
	if not this.reportclicked then
		local buttheight = 40*this.scale + this.hugefont:getHeight()  -- Report button
		local butty = love.graphics.getHeight() - buttheight - 1
		if y > butty then
			this.reportclicked = true
			this.reportThread = love.thread.newThread( ERRORMANAGER_PATH.."/reportthread.lua" )
			this.reportChannel = love.thread.getChannel( "sendreport" )
			local reporttext = tostring(GAMEVERSION).."\n"..ErrorManager.trace.."\n\n---rendererinfo---\n"

			local rname, rversion, gvendor, gdevice = love.graphics.getRendererInfo( )
			local os_string = love.system.getOS( )
			local cores = love.system.getProcessorCount( )
			local width,height,flags = love.window.getMode()
			local pixelscale = tostring(love.window.getPixelScale and love.window.getPixelScale())

			local loveversion = ""
			if love.getVersion then
				local vmajor, vminor, revision, codename = love.getVersion( )
				loveversion = string.format("Version %d.%d.%d: %s", vmajor, vminor, revision, codename)
			else
				loveversion = tostring(love._version)
			end

			reporttext = reporttext.."LOVE Version: ".. 	loveversion .."\n"
			reporttext = reporttext.."Renderer Name: ".. 	rname .."\n"
			reporttext = reporttext.."Renderer Version: ".. rversion .."\n"
			reporttext = reporttext.."Graphics Card Vendor: ".. gvendor .."\n"
			reporttext = reporttext.."Graphics Card: ".. 	gdevice .."\n"
			reporttext = reporttext.."OS: ".. 				os_string .."\n"
			reporttext = reporttext.."CPU Cores: ".. 		cores .."\n"

			reporttext = reporttext.."Width: ".. 			width .."\n"
			reporttext = reporttext.."Height: ".. 			height .."\n"
			reporttext = reporttext.."fullscreen: ".. 		tostring(flags["fullscreen"]) .."\n"
			reporttext = reporttext.."fullscreentype: ".. 	tostring(flags["fullscreentype"]) .."\n"
			reporttext = reporttext.."vsync: ".. 			tostring(flags["vsync"]) .."\n"
			reporttext = reporttext.."fsaa: ".. 			tostring(flags["fsaa"]) .."\n"
			reporttext = reporttext.."resizable: ".. 		tostring(flags["resizable"]) .."\n"
			reporttext = reporttext.."borderless: ".. 		tostring(flags["borderless"]) .."\n"
			reporttext = reporttext.."centered: ".. 		tostring(flags["centered"]) .."\n"
			reporttext = reporttext.."display: ".. 			tostring(flags["display"]) .."\n"
			reporttext = reporttext.."minwidth: ".. 		tostring(flags["minwidth"]) .."\n"
			reporttext = reporttext.."minheight: ".. 		tostring(flags["minheight"]) .."\n"
			reporttext = reporttext.."highdpi: ".. 			tostring(flags["highdpi"]) .."\n"
			reporttext = reporttext.."srgb: ".. 			tostring(flags["srgb"]) .."\n"
			reporttext = reporttext.."RAM used: ".. 		tostring(collectgarbage("count")) .."kb\n"
			reporttext = reporttext.."Pixelscale: ".. 		pixelscale .."\n"

			if love.graphics.isSupported then
				reporttext = reporttext.."\n--isSupported--\n"
				reporttext = reporttext.."canvas: ".. 			tostring(love.graphics.isSupported("canvas")) .."\n"
				reporttext = reporttext.."npot: ".. 			tostring(love.graphics.isSupported("npot")) .."\n"
				reporttext = reporttext.."subtractive: ".. 		tostring(love.graphics.isSupported("subtractive")) .."\n"
				reporttext = reporttext.."shader: ".. 			tostring(love.graphics.isSupported("shader")) .."\n"
				reporttext = reporttext.."hdrcanvas: ".. 		tostring(love.graphics.isSupported("hdrcanvas")) .."\n"
				reporttext = reporttext.."multicanvas: ".. 		tostring(love.graphics.isSupported("multicanvas")) .."\n"
				reporttext = reporttext.."mipmap: ".. 			tostring(love.graphics.isSupported("mipmap")) .."\n"
				reporttext = reporttext.."dxt: ".. 				tostring(love.graphics.isSupported("dxt")) .."\n"
				reporttext = reporttext.."bc5: ".. 				tostring(love.graphics.isSupported("bc5")) .."\n"
				reporttext = reporttext.."srgb: ".. 			tostring(love.graphics.isSupported("srgb")) .."\n"
			end
			if love.graphics.getSystemLimit then
				reporttext = reporttext.."\n--SystemLimit--\n"
				reporttext = reporttext.."pointsize: ".. 		 love.graphics.getSystemLimit("pointsize") .."\n"
				reporttext = reporttext.."texturesize: ".. 		 love.graphics.getSystemLimit("texturesize") .."\n"
				reporttext = reporttext.."multicanvas: ".. 		 love.graphics.getSystemLimit("multicanvas") .."\n"
				reporttext = reporttext.."canvasfsaa: ".. 		 love.graphics.getSystemLimit("canvasfsaa") .."\n"
			end

			reporttext = reporttext.."\n---printlog---\n"
			reporttext = reporttext.. table.concat(printtable, "\n") .."\n"


			this.reportThread:start(reporttext, "sendreport")
		end
	end
end
function ErrorManager.mousereleased(x, y, button)
	
end
function ErrorManager.run()
	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isCreated() then
		if not pcall(love.window.setMode, 800, 600) then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
	end
	if love.joystick then
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration() -- Stop all joystick vibrations.
		end
	end
	if love.audio then love.audio.stop() end
	love.graphics.reset()
	love.graphics.setBackgroundColor(89, 157, 220)
	

	love.graphics.setColor(255, 255, 255, 255)

	love.graphics.clear()
	love.graphics.origin()
	ErrorManager.load()
	while true do
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return
			end
			if e == "keypressed" and a == "escape" then
				return
			end
			if e == "mousepressed" then
				ErrorManager.mousepressed(a, b, c)
			end
			if e == "mousereleased" then
				ErrorManager.mousereleased(a, b, c)
			end
		end
		ErrorManager.update()
		love.graphics.clear()
		ErrorManager.draw()
		love.graphics.present()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end
end

function love.errhand(msg)
	-- function love.window.getPixelScale(...)
	--     return 1
	-- end
	if type(ErrorManager) == "table" then
		ErrorManager.msg = msg
	end

	local status, err = pcall(function() ErrorManager.trace = getTraceback(msg) end)
	ErrorManager.trace = ErrorManager.trace or ""
	if not status then
		ErrorManager.trace = ErrorManager.trace .. "\nError getting traceback:\n"..tostring(err).."\n"
	end

	local status, err = pcall(ErrorManager.run)
	if not status then
		ErrorManager.trace = ErrorManager.trace .. "\nError in ErrorManager.run:\n"..tostring(err).."\n"
		print(ErrorManager.trace)
		io.read()
	end
end