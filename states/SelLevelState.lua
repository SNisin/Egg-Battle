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
local this = {}
SelLevelState.this = this

local BUTTON_WIDTH = 0
local BUTTON_HEIGHT = 0

function SelLevelState.load()
	BUTTON_WIDTH = 50*pixelscale
	BUTTON_HEIGHT = 50*pixelscale
	this.buttonimg = RessourceManager.images.buttons.levelbutton
	this.finishedimg =  RessourceManager.images.buttons.levelfinished
	this.notavailableimg =  RessourceManager.images.buttons.levelnotavailable
	this.playedlevel = 1

	this.levels = LevelManager.worlds[1].levels
	this.numlevels = LevelManager.getNumLevels(1)
	this.worldId = 1

	this.customlevels = "no"  -- "no", "custom", myworld
end
function SelLevelState.enter(levels, worldid, customlevels)
	if type(levels) == "table" then
		this.levels = levels
		this.numlevels = #levels
		this.worldId = worldid
		this.customlevels = customlevels or "no"
	elseif type(levels) == "number" then
		this.customlevels = "no"
		this.levels = LevelManager.worlds[levels].levels
		this.numlevels = LevelManager.getNumLevels(levels)
		this.worldId = levels
	elseif levels == "next" then
		if this.customlevels ~= "myworld" then
			if this.levels[this.playedlevel+1] then
				this.playedlevel = this.playedlevel+1
				StateManager.setState("game", {	cmd="loadTable", 
												world=this.levels[this.playedlevel], 
												worldId=this.worldId, 
												levelId=this.playedlevel, 
												custom=this.customlevels})
			end
		end
	elseif levels == "myworld" or levels == "playmyworld" then
		this.customlevels = levels
		this.worldId = worldid
		this.levels = SaveManager.save.myworlds[worldid].levels
		this.numlevels = #this.levels

	else--if levels == "rettomenu" then
		SoundManager.playMusic("menu")
		this.playedlevel = 1
	end

	local numinrow, offs = this.getLevelVars()
	local rows = math.floor((this.numlevels-1)/numinrow)+1
	if this.customlevels == "myworld" then
		rows = math.floor((this.numlevels)/numinrow)+1
	end
	local contentheight = rows*(offs+BUTTON_HEIGHT)+offs

	this.scroll = ScrollManager.new({
		offTop = game.offY,
		clickcallback = this.mouseclicked,
		contentHeight = contentheight
	})


end
function SelLevelState.update(dt)
	this.scroll:update(dt)
end

function SelLevelState.draw()
	local numinrow, offs = this.getLevelVars()
	for i = 1, this.numlevels do
		this.drawLevelButton(i, (i-1)%numinrow*(love.graphics.getWidth()/numinrow)+offs, math.floor((i-1)/numinrow)*(BUTTON_HEIGHT+offs)+offs-this.scroll.scrollY)
	end
	if this.customlevels == "myworld" then
		local i = this.numlevels+1
		this.drawLevelButton("+", (i-1)%numinrow*(love.graphics.getWidth()/numinrow)+offs, math.floor((i-1)/numinrow)*(BUTTON_HEIGHT+offs)+offs-this.scroll.scrollY)
	end
	love.graphics.setColor(255,255,255,255)
	local barimg = RessourceManager.images.bar
	love.graphics.draw(barimg, 0, 0, 0, love.graphics.getWidth()/barimg:getWidth(), (50*pixelscale)/barimg:getHeight())
	ButtonManager.drawBackButton()
	
	this.scroll:drawScrollBar()
end

function SelLevelState.mousepressed(x, y, button)
	this.scroll:mousepressed(x, y, button)
end
function this.mouseclicked(x, y, button)
	if y > game.offY then
		local numinrow, offs = this.getLevelVars()
		for i = 1, this.numlevels do
			if ButtonManager.check((i-1)%numinrow*(love.graphics.getWidth()/numinrow)+offs, math.floor((i-1)/numinrow)*(BUTTON_HEIGHT+offs)+offs-this.scroll.scrollY, BUTTON_WIDTH, BUTTON_HEIGHT) then
				print("level "..i)
				if this.customlevels == "myworld" then
					this.playedlevel = i
					StateManager.addState("selection", 
					{
						{ret="edit",t="Edit"},
						{ret="play",t="Play"},
						{ret="move",t="Move"}, 
						{ret="delete",t="Delete"}
					})
				elseif LevelManager.canPlayLevel(this.worldId, i, this.customlevels) then
					this.playedlevel = i
					StateManager.setState("game", {	cmd="loadTable", 
													world=this.levels[i], 
													worldId=this.worldId, 
													levelId=i, 
													custom=this.customlevels})
					return
				end
			end
		end
		if this.customlevels == "myworld" then
			local i = this.numlevels+1
			if ButtonManager.check((i-1)%numinrow*(love.graphics.getWidth()/numinrow)+offs, math.floor((i-1)/numinrow)*(BUTTON_HEIGHT+offs)+offs-this.scroll.scrollY, BUTTON_WIDTH, BUTTON_HEIGHT) then
				print("add level "..i)
				table.insert(this.levels, {world={{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}},taps=1})
				this.numlevels = #this.levels
				SaveManager.saveGame()
				StateManager.setState("editor", "edit", this.worldId, i)
			end
		end
	else
		if ButtonManager.checkBackButton() then
			if this.customlevels == "custom" then
				StateManager.setState("customlevels")
			elseif this.customlevels == "no" then
				StateManager.setState("selectworld")
			elseif this.customlevels == "myworld" or this.customlevels == "playmyworld" then
				StateManager.setState("myworlds")
			end
		end
	end
end
function SelLevelState.keypressed(k)
	if k == "escape" then
		if this.customlevels == "custom" then
			StateManager.setState("customlevels")
		elseif this.customlevels == "no" then
			StateManager.setState("selectworld")
		elseif this.customlevels == "myworld" then
			StateManager.setState("myworlds")
		end
	end
end
function SelLevelState.mousereleased(x, y, button)
	this.scroll:mousereleased(x, y, button)
end
function SelLevelState.resize( width, height )
	local numinrow, offs = this.getLevelVars()
	local rows = math.floor((this.numlevels-1)/numinrow)+1
	if this.customlevels == "myworld" then
		rows = math.floor((this.numlevels)/numinrow)+1
	end
	local contentheight = rows*(offs+BUTTON_HEIGHT)+offs
	this.scroll:setContentHeight(contentheight)
end
function SelLevelState.returned( selection )
	if this.customlevels == "myworld" then
		if selection == "edit" then
			StateManager.setState("editor", "edit", this.worldId, this.playedlevel)
		elseif selection == "play" then
			StateManager.setState("game", {	cmd="loadTable", 
											world=this.levels[this.playedlevel], 
											worldId=this.worldId, 
											levelId=this.playedlevel, 
											custom=this.customlevels})
		elseif selection == "move" then

		elseif selection == "delete" then
			StateManager.addState("selection", 
				{	
					{t="Are you sure you want to delete this level?"},
					{ret="yesdelete",t="Yes"},
					{ret="nodelete",t="No"}
				})
		elseif selection == "yesdelete" then
			table.remove(this.levels, this.playedlevel)
			this.numlevels = #this.levels
			SaveManager.saveGame()
		elseif selection == "nodelete" then

		end
	end
end
function this.drawLevelButton(level, x, y)
	local drawimg
	if LevelManager.isLevelFinished(this.worldId, level, this.customlevels) then
		drawimg = this.finishedimg

	elseif LevelManager.canPlayLevel(this.worldId, level, this.customlevels) then
		drawimg = this.buttonimg
		
	else
		drawimg = this.notavailableimg

	end
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(drawimg, x, y, 0, BUTTON_WIDTH/drawimg:getWidth(), BUTTON_HEIGHT/drawimg:getHeight())
	
	
	love.graphics.setColor(255,255,255,255)
	love.graphics.printf(level, x, (BUTTON_HEIGHT-font:getHeight())/2+y, BUTTON_WIDTH, "center")
	
	love.graphics.setColor(0,0,0,255)
end

function this.getLevelVars()
	local numinrow = math.max(math.floor(love.graphics.getWidth()/(BUTTON_WIDTH*1.5)),1)
	local offs = (love.graphics.getWidth()/numinrow-BUTTON_WIDTH)/2
	return numinrow, offs
end

StateManager.registerState("selectlevel", SelLevelState)