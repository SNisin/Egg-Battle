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
local lg = love.graphics

function SelectionState.load()
	BUTTON_WIDTH = 300*pixelscale
	BUTTON_BORDER = 20
	this.entries = {}
	this.fEntries = {}
	this.boxHeight = 0
	this.boxWidth = 0
	this.boxX = 0
	this.boxY = 0
end
function SelectionState.enter(entries)
	this.entries = entries
	this.updateBox()
end

function SelectionState.draw()
	lg.setColor(128,128,128,128)
	lg.rectangle("fill", 0,0,lg.getWidth(),lg.getHeight())

	--lg.setColor(248,232,176) fill
	--lg.setColor(175,129,75) line
	--lg.setColor(255,255,220) note

	for i,v in pairs(this.fEntries) do

		if not v.ret then
			lg.setColor(255,255,220)
		else
			lg.setColor(248,232,176)
		end
		lg.rectangle("fill", this.boxX, this.boxY+v.y, v.w, v.h)
		lg.setColor(175,129,75)
		lg.rectangle("line", this.boxX, this.boxY+v.y, v.w, v.h)

		lg.setColor(0,0,0)
		lg.setFont(font)
		lg.printf(v.t, this.boxX+BUTTON_BORDER, this.boxY+v.y+BUTTON_BORDER, v.w-BUTTON_BORDER*2, "center")

	end
end
function SelectionState.mousereleased(x, y, button)
	for i,v in ipairs(this.fEntries) do
		if v.ret and ButtonManager.check(this.boxX, this.boxY+v.y, v.w, v.h, x, y) then
			print("[selection] return: "..v.ret)
			StateManager.retBack(v.ret)
			return
		end
	end
	print("[selection] return: nil")
	StateManager.retBack()
end
function SelectionState.keypressed(k)
	if k == "escape" then
		print("[selection] return: nil")
		StateManager.retBack()
	end
end
function SelectionState.resize( w, h )
	this.updateBox()
end
function this.updateBox()
	this.fEntries = {}
	this.boxWidth = math.min(lg.getWidth()-4, BUTTON_WIDTH)
	this.boxX = (lg.getWidth()-this.boxWidth)/2
	local cury = 0
	for i,v in ipairs(this.entries) do
		local width, lines = font:getWrap(v.t, this.boxWidth - BUTTON_BORDER*2)
		buttonHeight =  BUTTON_BORDER*2 + lines*font:getHeight()

		table.insert(this.fEntries, {t=v.t, ret=v.ret, y=cury, w=this.boxWidth, h=buttonHeight})

		cury = cury + buttonHeight
	end
	this.boxHeight = cury
	this.boxY = (lg.getHeight()-this.boxHeight)/2
end
StateManager.registerState("selection", SelectionState)