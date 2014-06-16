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

LostState = {}

function LostState.update(dt)
	-- Not called
end

function LostState.draw()
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(0,0,0,255)
	love.graphics.print("No moves left", (love.graphics.getWidth()-font:getWidth("No moves left"))/2+1, love.graphics.getHeight()/2-150*pixelscale+1)
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("No moves left", (love.graphics.getWidth()-font:getWidth("No moves left"))/2, love.graphics.getHeight()/2-150*pixelscale)
	
	drawButton(love.graphics.getHeight()/2-120*pixelscale, "Try again")
	if canPlayLevel(clvl.level+1, true) then
		drawButton(love.graphics.getHeight()/2, "Skip level")
	end
	drawButton(love.graphics.getHeight()/2+60*pixelscale, "Return to menu")
end

function LostState.mousepressed(x, y, button)
	if checkButton(nil, love.graphics.getHeight()/2-120*pixelscale) then
		loadLevel(clvl.level)
	end
	if checkButton(nil, love.graphics.getHeight()/2) and canPlayLevel(clvl.level+1, true) then
		loadLevel(clvl.level+1)
	end
	if checkButton(nil, love.graphics.getHeight()/2+60*pixelscale) then
		StateManager.setState("menu")
	end
end
StateManager.registerState("lost", LostState)