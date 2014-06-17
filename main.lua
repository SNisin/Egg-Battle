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

ButtonManager = require("lua.ButtonManager")
StateManager = require("lua.StateManager")
require("Tserial")
require("lua/buttons")
require("lua/save")
require("states/MenuState")
require("states/GameState")
require("states/WonState")
require("states/LostState")
require("states/EditorState")
require("states/SelWorldState")
require("states/SelLevelState")
require("states/CreditsState")
--lovebird = require "lovebird"

local AllState = {}
function AllState.load()
	love.filesystem.setIdentity("EggBattle")
	
	-- Images
	eggs = {
		[1] = love.graphics.newImage("gfx/eggs/1.png"),
		[2] = love.graphics.newImage("gfx/eggs/2.png"),
		[3] = love.graphics.newImage("gfx/eggs/3.png"),
		[4] = love.graphics.newImage("gfx/eggs/4.png")

	}
	cloudsimg = {
		[1] = love.graphics.newImage("gfx/clouds/cloud1.png"),
		[2] = love.graphics.newImage("gfx/clouds/cloud2.png")

	}
	logo = love.graphics.newImage("gfx/logo.png")
	backimg = love.graphics.newImage("gfx/back.png")
	barimg = love.graphics.newImage("gfx/bar.png")
	
	-- Sounds
	music = love.audio.newSource( "sfx/Sunny-Fields-Gallop.mp3", "stream" )
	music:setLooping( true )
	music:setVolume( 0.5 )
	music:play()
	
	hit = love.audio.newSource( "sfx/Hit.wav", "static" )
	
	-- Variables
	OS = love.system.getOS()
	timet = 0
	pixelscale = love.window.getPixelScale()
	font = love.graphics.newFont("gfx/font.ttf",math.floor(20*pixelscale))
	game = {
	}
	worlds = {
		"Boiled egg",
		"Coddled egg",
		"Fried egg",
		"Omelette",
		"Poached egg",
		"Scrambled eggs",
		"Basted egg",
		"Shirred eggs",
	}
	
	love.graphics.setFont(font)
	love.graphics.setLineWidth(pixelscale)
	love.graphics.setBackgroundColor(155, 200, 255)
	
	local contents
	if love.filesystem.isFile("levels.lua") then
		contents = love.filesystem.read("levels.lua")
	else
		contents = love.filesystem.read("levelsd.lua")
	end
	levels = Tserial.unpack(contents)
	
	load_game()
	
	clvl = {
		world={
			{0,0,0,0,0},
			{0,0,0,0,0},
			{0,0,0,0,0},
			{0,0,0,0,0},
			{0,0,0,0,0},
			{0,0,0,0,0}
		},
		taps=0,
		level=0,
		projectiles = {}
	}
	
	updateGraphics()
end
function AllState.update( dt )
	dt = math.min(dt, 0.1)
	local backscale = math.max(love.graphics.getWidth()/backimg:getWidth(), love.graphics.getHeight()/backimg:getHeight())
	timet = timet + dt
	for i, v in ipairs(clouds) do
		v.x = v.x-v.speed*dt
		if v.x<0-cloudsimg[v.type]:getWidth()*backscale then
			table.remove(clouds, i)
		end
	end
	if timet > cloudspawntime+5 then
		cloudspawntime = timet
		table.insert(clouds, {x=love.graphics.getWidth(), y=love.math.random(10, 200)*backscale, type=love.math.random(1,#cloudsimg), speed=love.math.random(30, 160)*backscale, op=love.math.random(50,200)})
	end
	if game.state then
		error("game.state changed to " .. game.state)
	end
end
function AllState.draw()
	love.graphics.setColor(255,255,255,255)
	local backscale = math.max(love.graphics.getWidth()/backimg:getWidth(), love.graphics.getHeight()/backimg:getHeight())
	love.graphics.draw(backimg, 0, -(backimg:getHeight()*backscale-love.graphics.getHeight()), 0, backscale, backscale)
	for i, v in ipairs(clouds) do
		love.graphics.setColor(255, 255, 255, v.op)
		love.graphics.draw(cloudsimg[v.type], v.x, v.y, 0, backscale, backscale)
	end
	

end
function AllState.mousepressed( mx, my, button )

end
function AllState.keypressed(k)

end
function AllState.mousereleased(x, y, button)

end
function AllState.resize( w, h )
	updateGraphics()
end

function updateGraphics()
	game.offY = 50*pixelscale 
	game.width=love.graphics.getWidth()
	game.height=love.graphics.getHeight()-game.offY
	game.tilew=game.width/#clvl.world[1]
	game.tileh=game.height/#clvl.world
	game.scaleX = (game.tilew-10)/eggs[1]:getWidth()
	game.scaleY = (game.tileh-10)/eggs[1]:getHeight()
	game.scale = math.min(game.scaleX, game.scaleY)
	game.eggofX = (game.tilew-eggs[1]:getWidth()*game.scale)/2
	game.eggofY = (game.tileh-eggs[1]:getHeight()*game.scale)/2
	
	local backscale = math.max(love.graphics.getWidth()/backimg:getWidth(), love.graphics.getHeight()/backimg:getHeight())
	clouds = {}
	cloudspawntime = -5
	table.insert(clouds, {x=love.math.random(-500*backscale, love.graphics.getWidth()), y=love.math.random(10, 200)*backscale, type=love.math.random(1,#cloudsimg), speed=love.math.random(30, 160)*backscale, op=love.math.random(50,200)})
	table.insert(clouds, {x=love.math.random(-500*backscale, love.graphics.getWidth()), y=love.math.random(10, 200)*backscale, type=love.math.random(1,#cloudsimg), speed=love.math.random(30, 160)*backscale, op=love.math.random(50,200)})
	table.insert(clouds, {x=love.math.random(-500*backscale, love.graphics.getWidth()), y=love.math.random(10, 200)*backscale, type=love.math.random(1,#cloudsimg), speed=love.math.random(30, 160)*backscale, op=love.math.random(50,200)})
	table.insert(clouds, {x=love.math.random(-500*backscale, love.graphics.getWidth()), y=love.math.random(10, 200)*backscale, type=love.math.random(1,#cloudsimg), speed=love.math.random(30, 160)*backscale, op=love.math.random(50,200)})
	table.insert(clouds, {x=love.math.random(-500*backscale, love.graphics.getWidth()), y=love.math.random(10, 200)*backscale, type=love.math.random(1,#cloudsimg), speed=love.math.random(30, 160)*backscale, op=love.math.random(50,200)})

	--table.insert(clouds, {x=500*backscale, y=20*backscale, type=2, speed=36*backscale, op=120})
	--table.insert(clouds, {x=944*backscale, y=70*backscale, type=2, speed=67*backscale, op=120})
	--table.insert(clouds, {x=0*backscale, y=67*backscale, type=2, speed=115*backscale, op=120})
	--table.insert(clouds, {x=732*backscale, y=87*backscale, type=2, speed=97*backscale, op=120})
	--table.insert(clouds, {x=123*backscale, y=17*backscale, type=2, speed=136*backscale, op=120})
end

function loadLevel(level)
	--print(level)
	if levels[level] then
		clvl.world = table.copy(levels[level].world, true)
		clvl.taps = levels[level].taps
		StateManager.setState("game")
		clvl.level = level
		clvl.projectiles = {}
	else
		StateManager.setState("menu")
	end
	
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

function table.copy(t, deep, seen)
    seen = seen or {}
    if t == nil then return nil end
    if seen[t] then return seen[t] end

    local nt = {}
    for k, v in pairs(t) do
        if deep and type(v) == 'table' then
            nt[k] = table.copy(v, deep, seen)
        else
            nt[k] = v
        end
    end
    setmetatable(nt, table.copy(getmetatable(t), deep, seen))
    seen[t] = nt
    return nt
end

StateManager.registerState("allstate", AllState)
StateManager.setAlwaysState("allstate")
StateManager.setState("menu")
StateManager.registerCallbacks()