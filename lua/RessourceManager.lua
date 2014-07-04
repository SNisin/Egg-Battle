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

local RessourceManager = {}

RessourceManager.images = {}
RessourceManager.sounds = {}

RessourceManager.loaded = false

function RessourceManager.load()
	if RessourceManager.loaded then
		return
	end

	-- Images
	RessourceManager.images = {
		eggs = {
			[1] = love.graphics.newImage("gfx/eggs/1.png"),
			[2] = love.graphics.newImage("gfx/eggs/2.png"),
			[3] = love.graphics.newImage("gfx/eggs/3.png"),
			[4] = love.graphics.newImage("gfx/eggs/4.png")
		},
		clouds = {
			[1] = love.graphics.newImage("gfx/clouds/cloud1.png"),
			[2] = love.graphics.newImage("gfx/clouds/cloud2.png")
		},
		buttons = {
			menu 				= love.graphics.newImage("gfx/buttons/button1.png"),
			worldbutton 		= love.graphics.newImage("gfx/buttons/worldbutton.png"),
			levelbutton 		= love.graphics.newImage("gfx/buttons/levelbutton.png"),
			levelfinished 		= love.graphics.newImage("gfx/buttons/levelfinished.png"),
			levelnotavailable 	= love.graphics.newImage("gfx/buttons/levelnotavailable.png"),

			reset = love.graphics.newImage("gfx/reset.png")
		},
		logo 		= love.graphics.newImage("gfx/logo.png"),
		background 	= love.graphics.newImage("gfx/back.png"),
		bar 		= love.graphics.newImage("gfx/bar.png"),

		muteoff = love.graphics.newImage("gfx/muteoff.png"),
		muteon = love.graphics.newImage("gfx/muteon.png")
	}


	-- Sounds
	RessourceManager.sounds = {
		music = {
			menu = love.audio.newSource( "sfx/Sunny-Fields-Gallop.ogg", "stream" ),
			game = love.audio.newSource( "sfx/Monkeys-Spinning-Monkeys.ogg", "stream" )
		},
		effects = {
			hit = love.audio.newSource( "sfx/Hit.ogg", "static" ),
			win = love.audio.newSource( "sfx/win.ogg", "static" ),
			lost = love.audio.newSource( "sfx/lost.ogg", "static" )
		}
	}
	RessourceManager.loaded = true
end

return RessourceManager