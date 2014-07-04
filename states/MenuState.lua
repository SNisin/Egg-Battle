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
	if SaveManager.loaded then
		this.setButtons()
	end
	this.muteoff = RessourceManager.images.muteoff
	this.muteon = RessourceManager.images.muteon
	
end
function MenuState.enter()
	if SaveManager.loaded then
		this.setButtons()
	end
	this.anim = {prog = love.window.getHeight()}
	this.animt = Tween.new(0.7, this.anim, {prog=0}, "outCubic")
	if this.notFirstTime then
		this.notMoveBack = true
	else
		this.notFirstTime = true
	end
	SoundManager.playMusic("menu")
end
function MenuState.update(dt)
	this.animt:update(dt)
end

function MenuState.draw()
	local logo = RessourceManager.images.logo
	love.graphics.setColor(255,255,255,255)
	local logoscale  = math.min(love.graphics.getWidth()/(logo:getWidth()*1.1), love.graphics.getHeight()/(logo:getHeight()*3))
	local logoY = (love.graphics.getHeight()/2-60*pixelscale)/2-logo:getHeight()*logoscale/2 
	love.graphics.draw(logo, (love.graphics.getWidth()-logo:getWidth()*logoscale)/2, logoY + this.anim.prog, 0, logoscale, logoscale)
	
	this.buttons:draw(this.anim.prog)
	if not this.notMoveBack then
		BackgroundManager.setOffY(this.anim.prog)
	end

	local mutewidth, muteheight = 48*pixelscale, 48*pixelscale
	local muteborder = 10*pixelscale
	local muteimage
	if not SoundManager.isMute() then
		muteimage = this.muteoff
	else
		muteimage = this.muteon
	end
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(muteimage, love.graphics.getWidth()-mutewidth-muteborder, muteborder, 0, mutewidth/muteimage:getWidth(), muteheight/muteimage:getHeight())
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

	local mutewidth, muteheight = 48*pixelscale, 48*pixelscale
	local muteborder = 10*pixelscale
	if ButtonManager.check(love.graphics.getWidth()-mutewidth-muteborder, muteborder, mutewidth, muteheight, x, y) then
		if not SoundManager.isMute() then
			SoundManager.setMute(true)
			save.mute = true
		else
			SoundManager.setMute(false)
			save.mute = false
		end
		save_game()
	end

	if y > love.graphics.getHeight()-10 then
		--StateManager.setState("editor")
	end
end

function MenuState.keypressed(k)
	if k == "x" then
		StateManager.setState("editor")
	elseif k == "r" then
		this.animt:reset()
	elseif k == "escape" then
		love.event.quit()
	end
end


function this.setButtons()
	this.buttons = this.buttons or ButtonManager.new()
	this.buttons:removeAllButtons()
	if SaveManager.save.crnt == 0 then
		this.buttons:addCenterButton("start", "Start Game", -60*pixelscale)
	else
		this.buttons:addCenterButton("continue", "Continue Game", -60*pixelscale)
	end
	this.buttons:addCenterButton("credits", "Credits", 50*pixelscale)
	this.buttons:addCenterButton("quit", "Quit", 130*pixelscale)
end

StateManager.registerState("menu", MenuState)
