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

SelectionState = {}
local this = {}
SelectionState.this = this

local BUTTON_WIDTH = 0
local BUTTON_HEIGHT = 0
local lg = love.graphics

function SelectionState.load()
	BUTTON_WIDTH = 300*pixelscale
	BUTTON_HEIGHT = 60*pixelscale
	this.entries = {}
end
function SelectionState.enter(entries)
	this.entries = entries
end

function SelectionState.draw()
	lg.setColor(128,128,128,128)
	lg.rectangle("fill", 0,0,lg.getWidth(),lg.getHeight())

	local rw = math.min(lg.getWidth()-4, BUTTON_WIDTH)
	local rh = BUTTON_HEIGHT * #this.entries
	
	local rx = (lg.getWidth()-rw)/2
	local ry = (lg.getHeight()-rh)/2

	local textOffY = (BUTTON_HEIGHT-font:getHeight())/2

	lg.setColor(248,232,176)
	lg.rectangle("fill", rx, ry, rw, rh)
	lg.setColor(175,129,75)
	lg.rectangle("line", rx, ry, rw, rh)
	lg.setColor(0,0,0)

	for i,v in pairs(this.entries) do
		if not v.ret then
			lg.setColor(255,255,220)
			lg.rectangle("fill", rx+1, ry+(i-1)*BUTTON_HEIGHT, rw-2, BUTTON_HEIGHT)
		end
		lg.setColor(0,0,0)
		lg.printf(v.t, rx, ry+(i-1)*BUTTON_HEIGHT+textOffY, rw, "center")
		lg.setColor(175,129,75)
		lg.line(rx, ry+i*BUTTON_HEIGHT, rx+rw, ry+i*BUTTON_HEIGHT)

	end
end
function SelectionState.mousereleased(x, y, button)
	local rw = math.min(lg.getWidth()-4, BUTTON_WIDTH)
	local rh = BUTTON_HEIGHT * #this.entries
	
	local rx = (lg.getWidth()-rw)/2
	local ry = (lg.getHeight()-rh)/2

	if x > rx and x < rx+rw and y > ry and y < ry+rh then
		for i,v in pairs(this.entries) do
			if y > ry + (i-1)*BUTTON_HEIGHT and y < ry + (i)*BUTTON_HEIGHT then
				if v.ret then
					print("[selection] return: "..tostring(v.ret))
					StateManager.retBack(v.ret)
				end
				break
			end
		end
	else
		StateManager.retBack()
	end
end
StateManager.registerState("selection", SelectionState)