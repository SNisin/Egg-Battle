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

SelLevelState = {}

local BUTTON_WIDTH = 0
local BUTTON_HEIGHT = 0

function SelLevelState.load()
	BUTTON_WIDTH = 50*pixelscale
	BUTTON_HEIGHT = 50*pixelscale
	
	levelClickedOn = 0
	levelClickedY = 0
	levelClickedScroll = -game.offY
	levelScroll = -game.offY
	levelNotSelect = true
end

function SelLevelState.update(dt)
	if love.mouse.isDown("l") and levelClickedOn ~= 0 then
		levelScroll = levelClickedScroll + (levelClickedY-love.mouse.getY())
	end
	
	local minoff, maxoff = getLevelMinMax()
	
	if levelScroll > maxoff then
		levelScroll = maxoff
	end
	if levelScroll < minoff then
		levelScroll = minoff
	end
	if math.abs(levelClickedY-love.mouse.getY()) > 30*pixelscale then
		levelNotSelect = true
	end
end

function SelLevelState.draw()
	local numinrow, offs = getLevelVars()
	for i = 1, 15 do
		drawLevelButton(i, (i-1)%numinrow*(love.graphics.getWidth()/numinrow)+offs, math.floor((i-1)/numinrow)*(BUTTON_HEIGHT+offs)+offs-levelScroll)
	end
	love.graphics.setColor(255,255,255,150)
	love.graphics.draw(barimg, 0, 0, 0, love.graphics.getWidth()/barimg:getWidth(), (50*pixelscale)/barimg:getHeight())
	drawButton(0, "< Back", 0, font:getWidth("< Back")+20*pixelscale)
	
	local minoff, maxoff = getLevelMinMax()
	if maxoff > minoff then
		love.graphics.setColor(0,0,0,150)
		rounded_rectangle("fill", love.graphics.getWidth()-15*pixelscale, math.floor((levelScroll+game.offY)/(maxoff+game.offY)*(love.graphics.getHeight()-150*pixelscale-game.offY*2)+game.offY), 5*pixelscale, 150*pixelscale, 2*pixelscale)
	end
end

function SelLevelState.mousepressed(x, y, button)
	if button == "l" then
		levelClickedY = y
		levelClickedScroll = levelScroll
		levelClickedOn = -1
		levelNotSelect = true
		if y > game.offY then
		for i = 1, 15 do
			local numinrow, offs = getLevelVars()
			if checkButton((i-1)%numinrow*(love.graphics.getWidth()/numinrow)+offs, math.floor((i-1)/numinrow)*(BUTTON_HEIGHT+offs)+offs-levelScroll, BUTTON_WIDTH, BUTTON_HEIGHT) then
				levelClickedOn = i
				levelNotSelect = false
			end
		end
		else
			if checkButton(0, 0, font:getWidth("< Back")+20*pixelscale, game.offY) then
				game.state = "selectworld"
			end
		end
	elseif button == "wu" then
		levelScroll = levelScroll-50*pixelscale
		
	elseif button == "wd" then
		levelScroll = levelScroll+50*pixelscale
	end
end
function SelLevelState.keypressed(k)
	if k == "escape" then
		game.state = "selectworld"
	end
end
function SelLevelState.mousereleased(x, y, button)
	if button == "l" then
		if not levelNotSelect then
			print("level "..levelClickedOn)
			if canPlayLevel(levelClickedOn) then
				loadLevel(15*(game.worldselected-1)+levelClickedOn)
			end
		end
		levelClickedOn = 0
	end
end
function drawLevelButton(level, x, y)
	if save.worlds and save.worlds[game.worldselected] and save.worlds[game.worldselected][level] then
		love.graphics.setColor(150,255,150,255)

	elseif canPlayLevel(level) then
		love.graphics.setColor(255,255,255,255)
		
	else
		love.graphics.setColor(150,150,150,255)

	end
	rounded_rectangle("fill", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, 10*pixelscale)
	love.graphics.setColor(0,0,0,255)
	rounded_rectangle("line", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, 10*pixelscale)
	
	

	love.graphics.setColor(0,160,160,255)
	love.graphics.printf(level, x, (BUTTON_HEIGHT-font:getHeight())/2+y, BUTTON_WIDTH, "center")
	
	love.graphics.setColor(0,0,0,255)
end

function getLevelVars()
	local numinrow = math.max(math.floor(love.graphics.getWidth()/(BUTTON_WIDTH*1.5)),1)
	local offs = (love.graphics.getWidth()/numinrow-BUTTON_WIDTH)/2
	return numinrow, offs
end

function getLevelMinMax()
	local numinrow, offs = getLevelVars()
	local rows = math.floor((14)/numinrow)+1
	return -game.offY, rows*(offs+BUTTON_HEIGHT)+offs - love.graphics.getHeight()
end
function canPlayLevel(level, all)
	if all then
		game.worldselected = math.floor((level-1)/15)+1
		level = (level-1)%15+1
		--print(game.worldselected, level)
	end
	if save.worlds and save.worlds[game.worldselected] and save.worlds[game.worldselected][level] then
		return true
	end
	local notmade = 3
	for i = 1,level-1 do
		if (not save.worlds) or (not save.worlds[game.worldselected]) or (not save.worlds[game.worldselected][i]) then
			notmade = notmade-1
		end
	end
	if notmade > 0 then
		return true
	end
	return false
end