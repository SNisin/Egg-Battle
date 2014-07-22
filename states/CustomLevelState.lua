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

local CustomLevelsState = {}
local this = {}
CustomLevelsState.this = this

function CustomLevelsState.load()
	this.levelList = nil
	this.scroll = ScrollManager.new({
		offTop = game.offY,
		clickcallback = this.mouseclicked,
	})
	this.boxheight = 100*pixelscale
	this.selectedlevel = 0
end
function CustomLevelsState.enter()
	this.levelList = nil
	this.selectedlevel = 0
	StateManager.addState("download", "http://eggbattle.bplaced.net/getList.php", "Getting list...")
end
function CustomLevelsState.returned(val)

	
	if type(val) == "table" and not val.error then
		if this.selectedlevel > 0 then

			local cuslevel = Tserial.unpack(val.world, true)
			StateManager.setState("selectlevel", cuslevel, this.selectedlevel, true)
		else
			this.levelList = val
			this.scroll:setContentHeight(#val*this.boxheight)
		end
	elseif type(val) == "table" and val.error then
		print("Error", val.errortype, val.errordesc)
		StateManager.setState("menu")
	else
		print("Error: not a table")
		StateManager.setState("menu")
	end
end
function CustomLevelsState.update(dt)
	if this.selectedlevel > 0 then

	end
	this.scroll:update(dt)
end
function CustomLevelsState.draw()
	if not this.levelList then return end
	local lg = love.graphics
	for i,v in ipairs(this.levelList) do
		local posY = (i-1)*this.boxheight-this.scroll.scrollY

		lg.setColor(248,232,176)
		lg.rectangle("fill", 0, posY, lg.getWidth(), this.boxheight)

		lg.setColor(175,129,75)
		lg.rectangle("line", 0, posY, lg.getWidth(), this.boxheight)

		lg.setColor(0,0,0)
		lg.print(v.name, 5*pixelscale, posY+5*pixelscale)

		lg.setFont(smallfont)
		lg.setColor(100,100,100)
		lg.printf("by "..v.username, 5*pixelscale, posY+this.boxheight-5*pixelscale-smallfont:getHeight(), lg.getWidth()-20*pixelscale, "right")

		lg.print(v.plays.." times played", 5*pixelscale, posY+this.boxheight-5*pixelscale-smallfont:getHeight())

		local numplayed = LevelManager.getWorldProgress(v.id, true)
		lg.setColor(100,100,100)
		local numlevelsY = posY+(this.boxheight-smallfont:getHeight())/2
		if numplayed > 0 then
			if numplayed >= v.numlevels then
				love.graphics.setColor(0,150,0,255)
			end
			lg.print(numplayed.."/"..v.numlevels.." levels played", 5*pixelscale, numlevelsY)
		else
			if numplayed > 1 then
				lg.print(v.numlevels.." levels", 5*pixelscale, numlevelsY)
			else
				lg.print(v.numlevels.." level", 5*pixelscale, numlevelsY)
			end
		end
		lg.setFont(font)



	end
	this.scroll:drawScrollBar()

	lg.setColor(255,255,255,150)
	local barimg = RessourceManager.images.bar
	lg.draw(barimg, 0, 0, 0, love.graphics.getWidth()/barimg:getWidth(), (50*pixelscale)/barimg:getHeight())
	ButtonManager.drawBackButton()
end
function this.mouseclicked(x, y)
	if y < game.offY then
		if ButtonManager.checkBackButton(x, y) then
			StateManager.setState("menu")
		end
	else
		local clickedlevel = math.floor((y+this.scroll.scrollY)/this.boxheight)+1
		if this.levelList[clickedlevel] then
			this.selectedlevel = clickedlevel
			StateManager.addState("download", "http://eggbattle.bplaced.net/getLevel.php?id="..this.levelList[clickedlevel].id, "Downloading level...")
		end
	end
end
function CustomLevelsState.mousepressed(x, y, button)
	this.scroll:mousepressed(x, y, button)
end
function CustomLevelsState.mousereleased(x, y, button)
	this.scroll:mousereleased(x, y, button)
end
function CustomLevelsState.keypressed(k)
	if k == "escape" then
		StateManager.setState("menu")
	end
end
StateManager.registerState("customlevels", CustomLevelsState)
