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
	this.levelList = {}
	this.scroll = ScrollManager.new({
		offTop = game.offY,
		clickcallback = this.mouseclicked,
	})
	this.boxheight = 100*pixelscale
end
function CustomLevelsState.enter()
	this.levelList = {}
	StateManager.addState("download", "http://eggbattle.bplaced.net/getList.php", "Getting list...")
end
function CustomLevelsState.returned(val)
	print(val)
	if type(val) == "table" and not val.error then
		this.levelList = val
		this.scroll:setContentHeight(#val*this.boxheight)
	elseif type(val) == "table" and val.error then
		print("Error", val.errortype, val.errordesc)
		StateManager.setState("menu")
	else
		print("Error: not a table")
		StateManager.setState("menu")
	end
end
function CustomLevelsState.update(dt)
	this.scroll:update(dt)
end
function CustomLevelsState.draw()
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
		lg.printf("by "..v.username, 5*pixelscale, posY+this.boxheight-5*pixelscale-smallfont:getHeight(), lg.getWidth()-10*pixelscale, "right")

		lg.print(v.plays.." times played", 5*pixelscale, posY+this.boxheight-5*pixelscale-smallfont:getHeight())
		lg.setFont(font)



	end
	this.scroll:drawScrollBar()

	lg.setColor(255,255,255,150)
	local barimg = RessourceManager.images.bar
	lg.draw(barimg, 0, 0, 0, love.graphics.getWidth()/barimg:getWidth(), (50*pixelscale)/barimg:getHeight())
	ButtonManager.drawBackButton()
end
function this.mouseclicked(x, y)
	if ButtonManager.checkBackButton(x, y) then
		StateManager.setState("menu")
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