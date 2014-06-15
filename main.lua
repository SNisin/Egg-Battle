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


function love.load()
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
	OS = "Android"
	timet = 0
	pixelscale = love.window.getPixelScale()
	font = love.graphics.newFont("gfx/font.ttf",math.floor(20*pixelscale))
	game = {
		state="menu"
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
	
	EditorState.load()
	GameState.load()
	SelWorldState.load()
	SelLevelState.load()
	CreditsState.load()
	
	

	--[[
	

		[7] = {
			world={
				{0,0,0,0,0},
				{0,0,0,0,0},
				{0,0,0,0,0},
				{0,0,0,0,0},
				{0,0,0,0,0},
				{0,0,0,0,0},
			},
			taps = 1
		},
	
	]]
end
function love.update( dt )
	--lovebird.update()
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
	if game.state == "game" then
		GameState.update(dt)
	elseif game.state == "menu" then
		MenuState.update(dt)
	elseif game.state == "selectworld" then
		SelWorldState.update(dt)
	elseif game.state == "selectlevel" then
		SelLevelState.update(dt)
	elseif game.state == "editor" then
		EditorState.update(dt)
	elseif game.state == "credits" then
		CreditsState.update(dt)
	end
end
function love.draw()
	love.graphics.setColor(255,255,255,255)
	local backscale = math.max(love.graphics.getWidth()/backimg:getWidth(), love.graphics.getHeight()/backimg:getHeight())
	love.graphics.draw(backimg, 0, -(backimg:getHeight()*backscale-love.graphics.getHeight()), 0, backscale, backscale)
	for i, v in ipairs(clouds) do
		love.graphics.setColor(255, 255, 255, v.op)
		love.graphics.draw(cloudsimg[v.type], v.x, v.y, 0, backscale, backscale)
	end
	
	if game.state == "game" then
		GameState.draw()
	elseif game.state == "menu" then
		MenuState.draw()
		
	elseif game.state == "won" then
		WonState.draw()
		
	elseif game.state == "lost" then
		LostState.draw()
		
	elseif game.state == "editor" then
		EditorState.draw()
		
	elseif game.state == "selectworld" then
		SelWorldState.draw()
		
	elseif game.state == "selectlevel" then
		SelLevelState.draw()
		
	elseif game.state == "credits" then
		CreditsState.draw()
	end
end
function love.mousepressed( mx, my, button )
	if game.state == "game" then
		GameState.mousepressed( mx, my, button )
		
	elseif game.state == "menu" then
		MenuState.mousepressed( mx, my, button )
		
	elseif game.state == "won" then
		WonState.mousepressed( mx, my, button )
		
	elseif game.state == "lost" then
		LostState.mousepressed( mx, my, button )
		
	elseif game.state == "editor" then
		EditorState.mousepressed( mx, my, button )
		
	elseif game.state == "selectworld" then
		SelWorldState.mousepressed(mx, my, button)
		
	elseif game.state == "selectlevel" then
		SelLevelState.mousepressed(mx, my, button)
		
	elseif game.state == "credits" then
		CreditsState.mousepressed(mx, my, button)
	end
end
function love.keypressed(k)
	if game.state == "editor" then
		EditorState.keypressed(k)
	elseif game.state == "game" then
		GameState.keypressed(k)
	elseif game.state == "selectworld" then
		SelWorldState.keypressed(k)
	elseif game.state == "selectlevel" then
		SelLevelState.keypressed(k)
	elseif game.state == "menu" then
		MenuState.keypressed(k)
	elseif game.state == "credits" then
		CreditsState.keypressed(k)
	end
end
function love.mousereleased(x, y, button)
	if game.state == "selectworld" then
		SelWorldState.mousereleased(x, y, button)
		
	elseif game.state == "selectlevel" then
		SelLevelState.mousereleased(x, y, button)
		
	elseif game.state == "credits" then
		CreditsState.mousereleased(x, y, button)
	end
end
function love.resize( w, h )
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
		game.state = "game"
		clvl.level = level
		clvl.projectiles = {}
	else
		game.state = "menu"
	end
	
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