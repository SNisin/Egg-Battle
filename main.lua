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

-- Managers
ButtonManager 		= require("lua.ButtonManager")
StateManager 		= require("lua.StateManager")
BackgroundManager 	= require("lua.BackgroundManager")
ScrollManager 		= require("lua.ScrollManager")
SoundManager 		= require("lua.SoundManager")
SaveManager			= require("lua.SaveManager")
RessourceManager	= require("lua.RessourceManager")
DownloadManager		= require("lua.DownloadManager")

-- Libraries
Tween = require("libs.tween")
		require("libs.Tserial")

-- Gamestates
require("states.MenuState")
require("states.GameState")
require("states.WonState")
require("states.LostState")
require("states.EditorState")
require("states.SelWorldState")
require("states.SelLevelState")
require("states.CreditsState")
require("states.CustomLevelState")
require("states.DownloadState")
require("states.SelCusLevelState")

local AllState = {}
function AllState.load()
	io.stdout:setvbuf("no")
	love.filesystem.setIdentity("EggBattle")

	SaveManager.loadGame()
	
	-- Images / Sounds
	RessourceManager.load()
	
	-- Sounds
	SoundManager.load(SaveManager.save.mute)
	SoundManager.playMusic("menu", true)
	
	-- Variables
	OS = love.system.getOS()
	timet = 0
	pixelscale = love.window.getPixelScale()
	font = love.graphics.newFont("gfx/font.ttf",math.floor(20*pixelscale))
	smallfont = love.graphics.newFont("gfx/font.ttf",math.floor(13*pixelscale))
	game = {
	}
	game.worldselected = 1
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
	love.graphics.setBackgroundColor(44, 209, 255)
	
	local contents
	if love.filesystem.isFile("levels.lua") then
		contents = love.filesystem.read("levels.lua")
	else
		contents = love.filesystem.read("levelsd.lua")
	end
	levels = Tserial.unpack(contents)
	
	
	
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
	BackgroundManager.load()

end
function AllState.update( dt )
	SoundManager.update(dt)
	BackgroundManager.update(dt)
	if game.state then
		error("game.state changed to " .. game.state)
	end
end
function AllState.draw()
	BackgroundManager.draw()
	love.graphics.setColor(255, 255, 255, 255)
	--love.graphics.print("Size: "..love.graphics.getWidth().."x"..love.graphics.getHeight(), 0, 0)
end
function AllState.mousepressed( mx, my, button )

end
function AllState.keypressed(k)

end
function AllState.mousereleased(x, y, button)

end
function AllState.resize( w, h )
	BackgroundManager.resize()
	updateGraphics()
end

function updateGraphics()
	local eggs = RessourceManager.images.eggs
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
	

	--table.insert(clouds, {x=500*backscale, y=20*backscale, type=2, speed=36*backscale, op=120})
	--table.insert(clouds, {x=944*backscale, y=70*backscale, type=2, speed=67*backscale, op=120})
	--table.insert(clouds, {x=0*backscale, y=67*backscale, type=2, speed=115*backscale, op=120})
	--table.insert(clouds, {x=732*backscale, y=87*backscale, type=2, speed=97*backscale, op=120})
	--table.insert(clouds, {x=123*backscale, y=17*backscale, type=2, speed=136*backscale, op=120})
end

function loadLevel(level)
	--print(level)
	game.customlevel = false
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
	if SaveManager.save.worlds and 
	   SaveManager.save.worlds[game.worldselected] and 
	   SaveManager.save.worlds[game.worldselected][level] then
		return true
	end
	local notmade = 3
	for i = 1,level-1 do
		if (not SaveManager.save.worlds) or 
		   (not SaveManager.save.worlds[game.worldselected]) or 
		   (not SaveManager.save.worlds[game.worldselected][i]) then
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
function table.merge(t1, t2)
    for k,v in pairs(t2) do
    	if type(v) == "table" then
    		if type(t1[k] or false) == "table" then
    			table.merge(t1[k] or {}, t2[k] or {})
    		else
    			t1[k] = v
    		end
    	else
    		t1[k] = v
    	end
    end
    return t1
end

StateManager.registerState("allstate", AllState)
StateManager.setAlwaysState("allstate")
StateManager.setState("menu")
StateManager.registerCallbacks()