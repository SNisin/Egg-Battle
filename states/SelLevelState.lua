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

local SelLevelState = {}
local this = {}
SelLevelState.this = this

local BUTTON_WIDTH = 0
local BUTTON_HEIGHT = 0

function SelLevelState.load()
	BUTTON_WIDTH = 50*pixelscale
	BUTTON_HEIGHT = 50*pixelscale
	this.buttonimg = love.graphics.newImage("gfx/buttons/levelbutton.png")
	this.finishedimg = love.graphics.newImage("gfx/buttons/levelfinished.png")
	this.notavailableimg = love.graphics.newImage("gfx/buttons/levelnotavailable.png")

end
function SelLevelState.enter()
	local numinrow, offs = this.getLevelVars()
	local rows = math.floor((14)/numinrow)+1
	local contentheight = rows*(offs+BUTTON_HEIGHT)+offs

	this.scroll = ScrollManager.new({
		offTop = game.offY,
		clickcallback = this.mouseclicked,
		contentHeight = contentheight
		})
end
function SelLevelState.update(dt)
	this.scroll:update(dt)
end

function SelLevelState.draw()
	local numinrow, offs = this.getLevelVars()
	for i = 1, 15 do
		this.drawLevelButton(i, (i-1)%numinrow*(love.graphics.getWidth()/numinrow)+offs, math.floor((i-1)/numinrow)*(BUTTON_HEIGHT+offs)+offs-this.scroll.scrollY)
	end
	love.graphics.setColor(255,255,255,150)
	love.graphics.draw(barimg, 0, 0, 0, love.graphics.getWidth()/barimg:getWidth(), (50*pixelscale)/barimg:getHeight())
	ButtonManager.drawBackButton()
	
	this.scroll:drawScrollBar()
end

function SelLevelState.mousepressed(x, y, button)
	this.scroll:mousepressed(x, y, button)
end
function this.mouseclicked(x, y, button)
	if y > game.offY then
		for i = 1, 15 do
			local numinrow, offs = this.getLevelVars()
			if ButtonManager.check((i-1)%numinrow*(love.graphics.getWidth()/numinrow)+offs, math.floor((i-1)/numinrow)*(BUTTON_HEIGHT+offs)+offs-this.scroll.scrollY, BUTTON_WIDTH, BUTTON_HEIGHT) then
				print("level "..i)
				if canPlayLevel(i) then
					loadLevel(15*(game.worldselected-1)+i)
				end
			end
		end
	else
		if ButtonManager.checkBackButton() then
			StateManager.setState("selectworld")
		end
	end
end
function SelLevelState.keypressed(k)
	if k == "escape" then
		StateManager.setState("selectworld")
	end
end
function SelLevelState.mousereleased(x, y, button)
	this.scroll:mousereleased(x, y, button)
end
function SelLevelState.resize( width, height )
	local numinrow, offs = this.getLevelVars()
	local rows = math.floor((14)/numinrow)+1
	local contentheight = rows*(offs+BUTTON_HEIGHT)+offs
	this.scroll:setContentHeight(contentheight)
end
function this.drawLevelButton(level, x, y)
	local drawimg
	if save.worlds and save.worlds[game.worldselected] and save.worlds[game.worldselected][level] then
		drawimg = this.finishedimg

	elseif canPlayLevel(level) then
		drawimg = this.buttonimg
		
	else
		drawimg = this.notavailableimg

	end
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(drawimg, x, y, 0, BUTTON_WIDTH/drawimg:getWidth(), BUTTON_HEIGHT/drawimg:getHeight())
	
	
	love.graphics.setColor(255,255,255,255)
	love.graphics.printf(level, x, (BUTTON_HEIGHT-font:getHeight())/2+y, BUTTON_WIDTH, "center")
	
	love.graphics.setColor(0,0,0,255)
end

function this.getLevelVars()
	local numinrow = math.max(math.floor(love.graphics.getWidth()/(BUTTON_WIDTH*1.5)),1)
	local offs = (love.graphics.getWidth()/numinrow-BUTTON_WIDTH)/2
	return numinrow, offs
end


StateManager.registerState("selectlevel", SelLevelState)