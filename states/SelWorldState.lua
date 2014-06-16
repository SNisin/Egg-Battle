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

function SelWorldState.load()
	BUTTON_WIDTH = 125*pixelscale
	BUTTON_HEIGHT = 125*pixelscale
	
	worldClickedOn = 0
	worldClickedY = 0
	worldClickedScroll = -game.offY
	worldScroll = -game.offY
	worldNotSelect = true
end

function SelWorldState.update(dt)
	if love.mouse.isDown("l") and worldClickedOn ~= 0 then
		worldScroll = worldClickedScroll + (worldClickedY-love.mouse.getY())
	end
	
	local minoff, maxoff = this.getWorldMinMax()
	
	if worldScroll > maxoff then
		worldScroll = maxoff
	end
	if worldScroll < minoff then
		worldScroll = minoff
	end
	if math.abs(worldClickedY-love.mouse.getY()) > 30*pixelscale then
		worldNotSelect = true
	end
end

function SelWorldState.draw()
	local numinrow, offs = this.getWorldVars()
	for i, v in ipairs(worlds) do
		if i<=math.floor(#levels/15) then
			this.drawWorldButton(i, (i-1)%numinrow*(love.graphics.getWidth()/numinrow)+offs, math.floor((i-1)/numinrow)*(BUTTON_HEIGHT+offs)+offs-worldScroll)
		end
	end
	love.graphics.setColor(255,255,255,150)
	love.graphics.draw(barimg, 0, 0, 0, love.graphics.getWidth()/barimg:getWidth(), (50*pixelscale)/barimg:getHeight())
	drawButton(0, "< Back", 0, font:getWidth("< Back")+20*pixelscale)
	
	local minoff, maxoff = this.getWorldMinMax()
	if maxoff > minoff then
		love.graphics.setColor(0,0,0,150)
		rounded_rectangle("fill", love.graphics.getWidth()-15*pixelscale, math.floor((worldScroll+game.offY)/(maxoff+game.offY)*(love.graphics.getHeight()-150*pixelscale-game.offY*2)+game.offY), 5*pixelscale, 150*pixelscale, 2*pixelscale)
	end
end

function SelWorldState.mousepressed(x, y, button)
	if button == "l" then
		worldClickedY = y
		worldClickedScroll = worldScroll
		worldClickedOn = -1
		worldNotSelect = true
		if y > game.offY then
			for i, v in ipairs(worlds) do
					if i<=math.floor(#levels/15) then
					local numinrow, offs = this.getWorldVars()
					if checkButton((i-1)%numinrow*(love.graphics.getWidth()/numinrow)+offs, math.floor((i-1)/numinrow)*(BUTTON_HEIGHT+offs)+offs-worldScroll, BUTTON_WIDTH, BUTTON_HEIGHT) then
						worldClickedOn = i
						worldNotSelect = false
					end
				end
			end
		else
			if checkButton(0, 0, font:getWidth("< Back")+20*pixelscale, game.offY) then
				StateManager.setState("menu")
			end
		end
	elseif button == "wu" then
		worldScroll = worldScroll-50*pixelscale
		
	elseif button == "wd" then
		worldScroll = worldScroll+50*pixelscale
	end
end
function SelWorldState.keypressed(k)
	if k == "escape" then
		StateManager.setState("menu")
	end
end
function SelWorldState.mousereleased(x, y, button)
	if button == "l" then
		if not worldNotSelect and worlds[worldClickedOn] then
			print("world "..worldClickedOn)
			game.worldselected = worldClickedOn
			StateManager.setState("selectlevel")
		end
		worldClickedOn = 0
	end
end
function this.drawWorldButton(world, x, y)
	
	local worldprog = 0
	if save.worlds and save.worlds[world] then
		for i, v in ipairs(save.worlds[world]) do
			if v then
				worldprog = worldprog + 1
			end
		end
	else
		worldprog = 0
	end
	if worldprog >= 15 then
		--love.graphics.setColor(220,220,220,255)
		love.graphics.setColor(150,255,150,255)
	else
		love.graphics.setColor(255,255,255,255)
	end
	rounded_rectangle("fill", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, 10*pixelscale)
	love.graphics.setColor(0,0,0,255)
	rounded_rectangle("line", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, 10*pixelscale)

	love.graphics.setColor(0,160,160,255)
	love.graphics.printf(world..". "..worlds[world], x, y+10, BUTTON_WIDTH, "center")
	
	love.graphics.setColor(0,0,0,255)
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

function this.getWorldMinMax()
	local numinrow, offs = this.getWorldVars()
	local rows = math.floor((math.floor(#levels/15)-1)/numinrow)+1
	return -game.offY, rows*(offs+BUTTON_HEIGHT)+offs - love.graphics.getHeight()
end

StateManager.registerState("selectworld", SelWorldState)