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

local CreditsState = {}
local this = {}
CreditsState.this = this

local colors = {
	link = {25, 34, 154},
	white = {255, 255, 255}
}
function CreditsState.load()
	creditsFonts = {
		[1] = font,
		[2] = love.graphics.newFont("gfx/font.ttf",math.floor(30*pixelscale))
	}
	
	creditLines = {
		{text="Programming", size=2, wrap=2},
		{text="Joemag", size=1, wrap=4},
		{text="Level Design", size=2, wrap=2},
		{text="Joemag", size=1, wrap=2},
		{text="AnnynN", size=1, wrap=4},
		{text="Music", size=2, wrap=2},
		{text="Sunny Fields Galloping by OctoEntandre ", size=1, wrap=1},
		{text="(Link)", size=1, link="http://www.newgrounds.com/audio/listen/525333", wrap=1, color="link"},
		{text="", size=1, wrap=4},
		{text="Font", size=2, wrap=2},
		{text="Kronika by Apostrophic Labs", size=1, wrap=1},
		{text="(Link)", size=1, link="http://www.dafont.com/kronika.font", wrap=1, color="link"},
		{text="", size=1, wrap=4},
		{text="Brushes", size=2, wrap=2},
		{text="My Grass Brushes by Archelerone ", size=1, wrap=1},
		{text="(Link)", size=1, link="http://archeleron.deviantart.com/art/My-Grass-Brushes-82240003", wrap=1, color="link"},
		{text="", size=1, wrap=2},
		{text="Cloud Brushes ver.3 by cloud-no9 ", size=1, wrap=1},
		{text="(Link)", size=1, link="http://www.deviantart.com/art/Cloud-Brushes-ver-3-59000409", wrap=1, color="link"},
		
		
		{text="", size=1, wrap=2},
		{image=love.graphics.newImage("gfx/love2d.png"), size=1, wrap=2, color="white", link="http://love2d.org/"},
		{text="", size=1, wrap=3},
		{image=love.graphics.newImage("gfx/oxyasa.png"), size=1, wrap=2, color="white", link="http://oxyasa.de/"},
		{text="", size=1, wrap=3},
	}
	
	creditlinks = {}
	creditHeight = 0
	
	creditsAutoScroll = 0
	
	creditsClickedOn = 0
	creditsClickedY = 0
	creditsClickedScroll = -game.offY
	creditsScroll = -game.offY -10*pixelscale
	creditsNotSelect = true
	if OS ~= "Android" then
		handcursor = love.mouse.getSystemCursor( "hand" )
		curcursor = ""
	end
end
function CreditsState.update(dt)
	if creditsAutoScroll <= 0 then
		creditsScroll = creditsScroll+20*dt*pixelscale
	else
		creditsAutoScroll = creditsAutoScroll -dt
	end
	if love.mouse.isDown("l") and creditsClickedOn ~= 0 then
		creditsScroll = creditsClickedScroll + (creditsClickedY-love.mouse.getY())
	end
	
	local minoff = -game.offY -10*pixelscale
	local maxoff = creditHeight - love.graphics.getHeight() +10*pixelscale
	if creditsScroll > maxoff then
		creditsScroll = maxoff
	end
	if creditsScroll < minoff then
		creditsScroll = minoff
	end
	if math.abs(creditsClickedY-love.mouse.getY()) > 30*pixelscale then
		creditsNotSelect = true
	end
	if OS ~= "Android" then
		local cursorchanged = false
		if love.mouse.getY() > game.offY then
			for i, v in ipairs(creditlinks) do
				if checkButton((love.graphics.getWidth()-v.width)/2, v.y, v.width, v.height) then
					if not (curcursor == "hand") then
						curcursor = "hand"
						love.mouse.setCursor( handcursor )
					end
					cursorchanged = true
				end
			end
		end
		if not cursorchanged then
			if not (curcursor == "") then
				curcursor = ""
				love.mouse.setCursor()
			end
		end
	end
end

function CreditsState.draw()
	love.graphics.setColor(255,255,255,100)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	--love.graphics.printf(CREDITSTEXT, 10*pixelscale, game.offY+10*pixelscale, love.graphics.getWidth()-20*pixelscale)
	
	local cposy = -creditsScroll
	local startcposy = cposy
	creditlinks = {}
	for i, v in ipairs(creditLines) do
		local cfont
		if v.size and creditsFonts[v.size] then
			cfont = creditsFonts[v.size]
		else
			cfont = font
		end
		love.graphics.setFont(cfont)
		if v.color and (type(v.color) == "table" or (type(v.color) == "string" and colors[v.color])) then
			if type(v.color) == "table" then
				love.graphics.setColor(unpack(v.color))
			elseif type(v.color) == "string" then
				love.graphics.setColor(colors[v.color])
			end
		else
			love.graphics.setColor(0,0,0,255)
		end
		local _width, nlines, _height
		if v.text then
			love.graphics.printf(v.text, 10*pixelscale, cposy, love.graphics.getWidth()-20*pixelscale, "center")
			_width, nlines = cfont:getWrap(v.text, love.graphics.getWidth()-20*pixelscale)
			nlines = nlines-1+(v.wrap or 1)
			_height = nlines*cfont:getHeight()
		end
		if v.image then
			local scale = math.min(math.min(love.graphics.getWidth()/v.image:getWidth(), love.graphics.getHeight()/v.image:getHeight()), pixelscale)
			_width = v.image:getWidth()* scale
			_height = v.image:getHeight()* scale
			love.graphics.draw(v.image, (love.graphics.getWidth()-_width)/2, cposy, 0, scale, scale)
		end
		
		--print(type(cfont))
		
		if v.link then
			table.insert(creditlinks, {link = v.link, y = cposy, width = _width, height = _height})
		end
		cposy = cposy + _height
		
		
	end
	creditHeight = cposy - startcposy
	
	love.graphics.setFont(font)
	
	local minoff = -game.offY -10*pixelscale
	local maxoff = creditHeight - love.graphics.getHeight() +10*pixelscale
	if maxoff > minoff then
		love.graphics.setColor(0,0,0,150)
		rounded_rectangle("fill", love.graphics.getWidth()-15*pixelscale, math.floor((creditsScroll-minoff)/(maxoff-minoff)*(love.graphics.getHeight()-150*pixelscale+minoff*2)-minoff), 5*pixelscale, 150*pixelscale, 2*pixelscale)
	end
	

	love.graphics.setColor(255,255,255,150)
	love.graphics.draw(barimg, 0, 0, 0, love.graphics.getWidth()/barimg:getWidth(), (50*pixelscale)/barimg:getHeight())
	drawButton(0, "< Back", 0, font:getWidth("< Back")+20*pixelscale)
end

function CreditsState.mousepressed(x, y, button)
	creditsAutoScroll = 3
	if button == "l" then
		creditsClickedY = y
		creditsClickedScroll = creditsScroll
		creditsClickedOn = -1
		creditsNotSelect = true
		if y > game.offY then
			for i, v in ipairs(creditlinks) do
				if checkButton((love.graphics.getWidth()-v.width)/2, v.y, v.width, v.height) then
					creditsNotSelect = false
					creditsClickedOn = v.link
				end
			end
		else
			if checkButton(0, 0, font:getWidth("< Back")+20*pixelscale, game.offY) then
				creditsClickedOn = 0
				StateManager.setState("menu")
			end
		end
	elseif button == "wu" then
		creditsScroll = creditsScroll-50*pixelscale
		
	elseif button == "wd" then
		creditsScroll = creditsScroll+50*pixelscale
	end
end
function CreditsState.mousereleased(x, y, button)
	
	if button == "l" then
		if creditsClickedOn ~= 0 then
			if not creditsNotSelect and type(creditsClickedOn) == "string" then
				if love.system and love.system.openURL then
					love.system.openURL(creditsClickedOn)
				end
			end
			creditsClickedOn = 0
			creditsAutoScroll = 3
		end
	end
end
function CreditsState.keypressed(k)
	if k == "escape" then
		StateManager.setState("menu")
	end
end

StateManager.registerState("credits", CreditsState)