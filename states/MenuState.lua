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

local MenuState = {}
local this = {}
MenuState.this = this


function MenuState.load()
	if save then
		this.setButtons()
	end
	
end
function MenuState.enter(notMoveBack)
	if save then
		this.setButtons()
	end
	this.notMoveBack = notMoveBack or false
	this.anim = {prog = love.window.getHeight()}
	this.animt = Tween.new(0.7, this.anim, {prog=0}, "outCubic")
end
function MenuState.update(dt)
	this.animt:update(dt)
end

function MenuState.draw()
	love.graphics.setColor(255,255,255,255)
	local logoscale  = math.min(love.graphics.getWidth()/(logo:getWidth()*1.1), love.graphics.getHeight()/(logo:getHeight()*3))
	local logoY = (love.graphics.getHeight()/2-60*pixelscale)/2-logo:getHeight()*logoscale/2 
	love.graphics.draw(logo, (love.graphics.getWidth()-logo:getWidth()*logoscale)/2, logoY + this.anim.prog, 0, logoscale, logoscale)
	
	this.buttons:draw(this.anim.prog)
	if not this.notMoveBack then
		BackgroundManager.setOffY(this.anim.prog)
	end
end

function MenuState.mousepressed(x, y, button)
	local clickedbutton = this.buttons:getClickedButton(x, y)
		
	if clickedbutton == "start" then
		loadLevel(1)
	end

	if clickedbutton == "continue" then
		StateManager.setState("selectworld")
	end

	if clickedbutton == "credits" then
		creditsScroll = -game.offY -10*pixelscale
		creditsAutoScroll = 0
		StateManager.setState("credits")
	end
	if clickedbutton == "quit" then
		love.event.quit()
	end

	
	if y > love.graphics.getHeight()-10 then
		--StateManager.setState("editor")
	end
end

function MenuState.keypressed(k)
	if k == "x" then
		--StateManager.setState("editor")
	elseif k == "r" then
		this.animt:reset()
	elseif k == "escape" then
		love.event.quit()
	end
end


function this.setButtons()
	this.buttons = this.buttons or ButtonManager.new()
	this.buttons:removeAllButtons()
	if save.crnt == 0 then
		this.buttons:addCenterButton("start", "Start Game", -60*pixelscale)
	else
		this.buttons:addCenterButton("continue", "Continue Game", -60*pixelscale)
	end
	this.buttons:addCenterButton("credits", "Credits", 50*pixelscale)
	this.buttons:addCenterButton("quit", "Quit", 130*pixelscale)
end

StateManager.registerState("menu", MenuState)