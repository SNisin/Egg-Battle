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

local EditorState = {}
local this = {}
EditorState.this = this

function EditorState.load()
	this.world = {}
	this.eggs = RessourceManager.images.eggs
	this.message = ""
	this.messageop = 0
	this.menubutton = RessourceManager.images.buttons.moremenu

	this.changedAfterSaving = false

	this.myworldid = 0
	this.levelid = 0
end
function EditorState.enter(action, message1, message2)
	if action == "return" then
		this.message = message1 or ""
		this.messageop = 255
	elseif action == "edit" then
		if SaveManager.save.myworlds[message1] and SaveManager.save.myworlds[message1].levels[message2] then
			this.myworldid = message1
			this.levelid = message2
			this.world = table.copy(SaveManager.save.myworlds[message1].levels[message2].world, true)
			this.taps = SaveManager.save.myworlds[message1].levels[message2].taps

			this.changedAfterSaving = false
		else
			StateManager.setState("menu")
		end
		
	else
		StateManager.setState("menu")
	end
	SoundManager.playMusic("game")
end

function EditorState.update(dt)
	if this.messageop > 0 then
		this.messageop = this.messageop - 128*dt
		if this.messageop < 0 then this.messageop = 0 end
	end
end

function EditorState.draw()
	local lg = love.graphics
	love.graphics.setColor(0,0,0,100)
	for y =1, #this.world do
		love.graphics.rectangle("fill", 0, (y-1)*game.tileh+game.offY, love.graphics.getWidth(), 2)
	end
	for x =1, #this.world[1] do
		love.graphics.rectangle("fill", (x-1)*game.tilew, game.offY, 2, love.graphics.getHeight())
	end
	
	love.graphics.setColor(255,255,255,255)
	for y,v in ipairs(this.world) do
		for x,v2 in ipairs(v) do
			if this.eggs[v2] then
				love.graphics.draw(this.eggs[v2], (x-1)*game.tilew+game.eggofX, (y-1)*game.tileh+game.eggofY +game.offY, 0, game.scale, game.scale)
			end
		end
	end
	love.graphics.setColor(255,255,255,255)
	local barimg = RessourceManager.images.bar
	love.graphics.draw(barimg, 0, 0, 0, love.graphics.getWidth()/barimg:getWidth(), (50*pixelscale)/barimg:getHeight())
	

	love.graphics.setColor(255,255,255,255)
	local menuwidth, menuwidth = 32*pixelscale, 32*pixelscale
	local offset = (game.offY-menuwidth)/2
	love.graphics.draw(this.menubutton, love.graphics.getWidth()-menuwidth-offset, offset, 0, menuwidth/this.menubutton:getWidth(), menuwidth/this.menubutton:getHeight())
	
	love.graphics.setColor(255,255,255,this.messageop)
	love.graphics.print(this.message, (love.graphics.getWidth() - font:getWidth(this.message))/2, (game.offY-font:getHeight())/2)


	love.graphics.setColor(255,255,255)
	lg.print("Play", 10*pixelscale, (game.offY-font:getHeight())/2)
end

function EditorState.mousereleased(mx, my, button)
	--if my > love.graphics.getHeight()-10 then
	--	EditorState.keypressed("return")
	--	return
	--end
	if my <= game.offY then
		local menuwidth, menuwidth = 32*pixelscale, 32*pixelscale
		local offset = (game.offY-menuwidth)/2

		if mx < font:getWidth("Play")+20*pixelscale then
			print("[Editor] Play")
			StateManager.setState("game", {world=this.world, taps=this.taps}, 1, 1, "edit")
		elseif mx > love.graphics.getWidth()-(menuwidth+offset*2) then
			print("[Editor] Menu")
			StateManager.addState("selection", 
				{
					{ret="save",t="Save"},
					{ret="numtaps",t="Number of taps"},
					{ret="exit",t="Exit"}
				})
		end
	else
		local x = math.floor(mx/game.tilew)+1
		local y = math.floor((my-game.offY)/game.tileh)+1
		if this.world[y] and this.world[y][x] then
			if button == "wu" then
				this.world[y][x] = this.world[y][x] + 1
				if this.world[y][x]>#this.eggs then this.world[y][x] = #this.eggs end
			elseif button == "wd" then
				this.world[y][x] = this.world[y][x] - 1
				if this.world[y][x]<0 then this.world[y][x] = 0 end
			end
			if button == "l" then
				this.world[y][x] = this.world[y][x] + 1
				if this.world[y][x]>#this.eggs then this.world[y][x] = 0 end
			end
			if button == "r" then
				this.world[y][x] = this.world[y][x] - 1
				if this.world[y][x]<0 then this.world[y][x] = #this.eggs end
			end
			this.changedAfterSaving = true
		end
	end
	
end

function EditorState.keypressed(k)
	
end
function EditorState.returned( ret )
	if ret == "save" then
		this.save()
	elseif ret == "exit" then
		this.exit()

	elseif ret == "saveexit" then
		this.save()
		StateManager.setState("selectlevel")
	elseif ret == "notsaveexit" then
		StateManager.setState("selectlevel")
	end
end

function this.save()
	SaveManager.save.myworlds[this.myworldid].levels[this.levelid].world = table.copy(this.world)
	SaveManager.save.myworlds[this.myworldid].levels[this.levelid].taps = this.taps
	SaveManager.saveGame()
	this.message = "Saved!"
	this.messageop = 255
	this.changedAfterSaving = false
end

function this.exit()
	if this.changedAfterSaving then
		StateManager.addState("selection", 
		{
			{t="Do you want to save?"},
			{ret="saveexit",t="Save"},
			{ret="notsaveexit",t="Don't save"}
		})
	else
		StateManager.setState("selectlevel")
	end
end

function checkempty(wld)
	wld = wld or edit.world
	for y,v in ipairs(wld) do
		for x,v2 in ipairs(v) do
			if this.eggs[v2] then
				return false
			end
		end
	end
	return true
end


StateManager.registerState("editor", EditorState)