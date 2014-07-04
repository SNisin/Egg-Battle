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

local SelWorldState = {}
local this = {}
SelWorldState.this = this

local BUTTON_WIDTH = 0
local BUTTON_HEIGHT = 0
local BUTTON_BORDER = 0

function SelWorldState.load()

	BUTTON_WIDTH = 130*pixelscale
	BUTTON_HEIGHT = 130*pixelscale
	BUTTON_BORDER = 10*pixelscale
	this.buttonimg = love.graphics.newImage("gfx/buttons/worldbutton.png")
end
function SelWorldState.enter()
	SoundManager.playMusic("menu")
	local numinrow, offs = this.getWorldVars()
	local rows = math.floor((math.floor(#levels/15)-1)/numinrow)+1
	local contentheight = rows*(offs+BUTTON_HEIGHT)+offs

	this.scroll = ScrollManager.new({
		offTop = game.offY,
		clickcallback = this.mouseclicked,
		contentHeight = contentheight
		})
end

function SelWorldState.update(dt)
	this.scroll:update(dt)
end

function SelWorldState.draw()
	local numinrow, offs = this.getWorldVars()
	for i, v in ipairs(worlds) do
		if i<=math.floor(#levels/15) then
			this.drawWorldButton(i, (i-1)%numinrow*(love.graphics.getWidth()/numinrow)+offs, math.floor((i-1)/numinrow)*(BUTTON_HEIGHT+offs)+offs-this.scroll.scrollY)
		end
	end
	love.graphics.setColor(255,255,255,150)
	love.graphics.draw(barimg, 0, 0, 0, love.graphics.getWidth()/barimg:getWidth(), (50*pixelscale)/barimg:getHeight())
	ButtonManager.drawBackButton()

	this.scroll:drawScrollBar()
end

function SelWorldState.mousepressed(x, y, button)
	this.scroll:mousepressed(x, y, button)
end
function this.mouseclicked(x, y, button)
	if y > game.offY then
		for i, v in ipairs(worlds) do
				if i<=math.floor(#levels/15) then
				local numinrow, offs = this.getWorldVars()
				if ButtonManager.check((i-1)%numinrow*(love.graphics.getWidth()/numinrow)+offs, math.floor((i-1)/numinrow)*(BUTTON_HEIGHT+offs)+offs-this.scroll.scrollY, BUTTON_WIDTH, BUTTON_HEIGHT) then
					print("world "..i)
					game.worldselected = i
					StateManager.setState("selectlevel")
				end
			end
		end
	else
		if ButtonManager.checkBackButton(mx, my) then
			StateManager.setState("menu")
		end
	end
end
function SelWorldState.keypressed(k)
	if k == "escape" then
		StateManager.setState("menu")
	end
end
function SelWorldState.mousereleased(x, y, button)
	this.scroll:mousereleased(x, y, button)
end
function SelWorldState.resize(width, height)
	local numinrow, offs = this.getWorldVars()
	local rows = math.floor((math.floor(#levels/15)-1)/numinrow)+1
	local contentheight = rows*(offs+BUTTON_HEIGHT)+offs
	this.scroll:setContentHeight(contentheight)
end
function this.drawWorldButton(world, x, y)
	
	local worldprog = 0
	if SaveManager.save.worlds and SaveManager.save.worlds[world] then
		for i, v in ipairs(SaveManager.save.worlds[world]) do
			if v then
				worldprog = worldprog + 1
			end
		end
	else
		worldprog = 0
	end
	local drawimg = this.buttonimg
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(drawimg, x, y, 0, BUTTON_WIDTH/drawimg:getWidth(), BUTTON_HEIGHT/drawimg:getHeight())

	love.graphics.setColor(0,160,160,255)
	love.graphics.printf(world..". "..worlds[world], x+BUTTON_BORDER, y+10, BUTTON_WIDTH-BUTTON_BORDER*2, "center")
	
	if worldprog >= 15 then
		love.graphics.setColor(0,150,0,255)
	else
		love.graphics.setColor(0,0,0,255)
	end
	love.graphics.printf(worldprog.."/15", x, y+BUTTON_HEIGHT-10-font:getHeight(), BUTTON_WIDTH, "center")
end

function this.getWorldVars()
	local numinrow = math.max(math.floor(love.graphics.getWidth()/(BUTTON_WIDTH*1.2)),1)
	--if love.graphics.getWidth() < BUTTON_WIDTH*2 then
	--	numinrow = 1
	--end
	local offs = (love.graphics.getWidth()/numinrow-BUTTON_WIDTH)/2
	return numinrow, offs
end

StateManager.registerState("selectworld", SelWorldState)
