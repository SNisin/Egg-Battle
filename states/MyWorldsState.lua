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

local MyWorldsState = {}
local this = {}
MyWorldsState.this = this

local BUTTON_WIDTH = 0
local BUTTON_HEIGHT = 0
local BUTTON_BORDER = 0


function MyWorldsState.load()
	BUTTON_WIDTH = 130*pixelscale
	BUTTON_HEIGHT = 130*pixelscale
	BUTTON_BORDER = 10*pixelscale
	this.buttonimg = RessourceManager.images.buttons.worldbutton
	this.levels = SaveManager.save.myworlds
	this.selectedworld = 1
end
function MyWorldsState.enter()
	SoundManager.playMusic("menu")
	local numinrow, offs = this.getWorldVars()
	local rows = math.floor(#this.levels/numinrow)
	local contentheight = rows*(offs+BUTTON_HEIGHT)+offs
	
	this.scroll = ScrollManager.new({
		offTop = game.offY,
		clickcallback = this.mouseclicked,
		contentHeight = contentheight
	})
end

function MyWorldsState.update(dt)
	this.scroll:update(dt)
end

function MyWorldsState.draw()
	local numinrow, offs = this.getWorldVars()
	for i, v in ipairs(this.levels) do
		this.drawWorldButton(i, v)
		--if i<=math.floor(#levels/15) then
			--this.drawWorldButton(i, (i-1)%numinrow*(love.graphics.getWidth()/numinrow)+offs, math.floor((i-1)/numinrow)*(BUTTON_HEIGHT+offs)+offs-this.scroll.scrollY)
		--end
	end
	this.drawWorldButton(#this.levels + 1, {}, true)
	love.graphics.setColor(255,255,255,255)
	local barimg = RessourceManager.images.bar
	love.graphics.draw(barimg, 0, 0, 0, love.graphics.getWidth()/barimg:getWidth(), (50*pixelscale)/barimg:getHeight())
	ButtonManager.drawBackButton()

	this.scroll:drawScrollBar()
end

function MyWorldsState.mousepressed(x, y, button)
	this.scroll:mousepressed(x, y, button)
end
function this.mouseclicked(x, y, button)
	if y > game.offY then
		local hit = false
		for i, v in ipairs(this.levels) do
			local numinrow, offs = this.getWorldVars()
			if ButtonManager.check((i-1)%numinrow*(love.graphics.getWidth()/numinrow)+offs, math.floor((i-1)/numinrow)*(BUTTON_HEIGHT+offs)+offs-this.scroll.scrollY, BUTTON_WIDTH, BUTTON_HEIGHT) then
				print("[myworlds] world "..i)
				hit = true
				this.selectedworld = i
				StateManager.addState("selection", 
					{
						{ret="edit",t="Edit"},
						{ret="play",t="Play"},
						{ret="rename",t="Rename"}, 
						{ret="delete",t="Delete"}
					})
				return
			end
		end
		if not hit then
			local i = #this.levels + 1
			local numinrow, offs = this.getWorldVars()
			if ButtonManager.check((i-1)%numinrow*(love.graphics.getWidth()/numinrow)+offs, math.floor((i-1)/numinrow)*(BUTTON_HEIGHT+offs)+offs-this.scroll.scrollY, BUTTON_WIDTH, BUTTON_HEIGHT) then
				print("[myworlds] new world")
				this.levels[i] = {
					name = "New World "..i,
					levels = {}
				}
				SaveManager.saveGame()
				StateManager.setState("selectlevel", "myworld", i)
			end
		end
	else
		if ButtonManager.checkBackButton(mx, my) then
			StateManager.setState("menu")
		end
	end
end
function MyWorldsState.keypressed(k)
	if k == "escape" then
		StateManager.setState("menu")
	end
end
function MyWorldsState.mousereleased(x, y, button)
	this.scroll:mousereleased(x, y, button)
end
function MyWorldsState.resize(width, height)
	local numinrow, offs = this.getWorldVars()
	local rows = math.floor(#this.levels/numinrow)
	local contentheight = rows*(offs+BUTTON_HEIGHT)+offs
	this.scroll:setContentHeight(contentheight)
end
function MyWorldsState.returned(selection)
	if selection then
		
		if selection == "edit" then
			StateManager.setState("selectlevel", "myworld", this.selectedworld)
		elseif selection == "play" then
			StateManager.setState("selectlevel", "playmyworld", this.selectedworld)
		elseif selection == "rename" then

		elseif selection == "delete" then
			StateManager.addState("selection", 
				{	
					{t="Are you sure you want to delete\n\""..this.levels[this.selectedworld].name.."\"?"},
					{ret="yesdelete",t="Yes"},
					{ret="nodelete",t="No"}
				})
		elseif selection == "yesdelete" then
			table.remove(this.levels, this.selectedworld)
			SaveManager.saveGame()
		elseif selection == "nodelete" then

		end
	end
end
function this.drawWorldButton(worldnum, world, addworld)
	local numinrow, offs = this.getWorldVars()
	local x = (worldnum-1)%numinrow*(love.graphics.getWidth()/numinrow)+offs
	local y = math.floor((worldnum-1)/numinrow)*(BUTTON_HEIGHT+offs)+offs-this.scroll.scrollY

	local drawimg = this.buttonimg
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(drawimg, x, y, 0, BUTTON_WIDTH/drawimg:getWidth(), BUTTON_HEIGHT/drawimg:getHeight())

	if not addworld then
		love.graphics.setColor(0,160,160,255)
		love.graphics.printf(worldnum..". "..world.name, x+BUTTON_BORDER, y+10, BUTTON_WIDTH-BUTTON_BORDER*2, "center")
		

		love.graphics.setColor(0,0,0,255)

		local numlevels = #this.levels[worldnum]
		love.graphics.printf(numlevels.." levels", x, y+BUTTON_HEIGHT-10-font:getHeight(), BUTTON_WIDTH, "center")
	else
		love.graphics.setColor(0,160,160,255)
		love.graphics.printf("New World", x+BUTTON_BORDER, y+10, BUTTON_WIDTH-BUTTON_BORDER*2, "center")
	end
end

function this.getWorldVars()
	local numinrow = math.max(math.floor(love.graphics.getWidth()/(BUTTON_WIDTH*1.2)),1)
	--if love.graphics.getWidth() < BUTTON_WIDTH*2 then
	--	numinrow = 1
	--end
	local offs = (love.graphics.getWidth()/numinrow-BUTTON_WIDTH)/2
	return numinrow, offs
end


StateManager.registerState("myworlds", MyWorldsState)
