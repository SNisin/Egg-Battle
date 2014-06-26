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

local WonState = {}
local this = {}
WonState.this = this

function WonState.load()
	this.buttons = ButtonManager.new()
end
function WonState.enter()
	this.buttons:removeAllButtons()
	this.buttons:addCenterButton("next", "Next level", -120*pixelscale)
	this.buttons:addCenterButton("tryagain", "Try again", 0)
	this.buttons:addCenterButton("menu", "Return to menu", 80*pixelscale)
end
function WonState.draw()
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(0,0,0,255)
	love.graphics.print("Level "..clvl.level.." succeeded", (love.graphics.getWidth()-font:getWidth("Level "..clvl.level.." succeeded"))/2+1, love.graphics.getHeight()/2-150*pixelscale+1)
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("Level "..clvl.level.." succeeded", (love.graphics.getWidth()-font:getWidth("Level "..clvl.level.." succeeded"))/2, love.graphics.getHeight()/2-150*pixelscale)
	
	this.buttons:draw()
end

function WonState.mousepressed(x, y, button)
	local clickedbutton = this.buttons:getClickedButton(x, y)
	if clickedbutton == "next" then
		if (clvl.level-1)%15 == 14 then
			StateManager.setState("selectworld")
		else
			loadLevel(clvl.level+1)
		end
	end
	if clickedbutton == "tryagain" then
		loadLevel(clvl.level)
	end
	if clickedbutton == "menu" then
		StateManager.setState("menu")
	end
end

StateManager.registerState("won", WonState)