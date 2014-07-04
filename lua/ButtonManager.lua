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

local ButtonManager = {}
ButtonManager.__index = ButtonManager

function ButtonManager.new()
	local t = {}
	setmetatable(t, ButtonManager)
	t.buttons = {}
	return t
end
function ButtonManager:draw(offY)
	for i, v in ipairs(self.buttons) do
		local text, x, y, w, h = v.text, v.x, v.y, v.w, v.h
		if x == "c" then
			x = (love.graphics.getWidth()-w)/2
			y = love.graphics.getHeight()/2 + y
		end
		y = y + (offY or 0)
		love.graphics.setColor(255,255,255,255)
		local buttonimg =  RessourceManager.images.buttons.menu
		love.graphics.draw(buttonimg, x, y, 0, w/buttonimg:getWidth(), h/buttonimg:getHeight())
		
		love.graphics.setColor(0,0,0,255)
		love.graphics.print(text, x+(w-font:getWidth(text))/2, y + (h - font:getHeight())/2)
	end
end
function ButtonManager:getClickedButton(mx, my)
	mx = mx or love.mouse.getX()
	my = my or love.mouse.getY()
	for i, v in ipairs(self.buttons) do
		if self.check(v.x, v.y, v.w, v.h, mx, my) then
			return v.name
		end
	end
end
function ButtonManager:addButton(name, text, x, y, w)
	w = w or 300*pixelscale
	h = h or 50*pixelscale
	
	table.insert(self.buttons, {name = name, text = text, x = x, y = y, w = w, h = h})
end
function ButtonManager:addCenterButton(name, text, y, w, h)
	w = w or 300*pixelscale
	h = h or 75*pixelscale
	

	table.insert(self.buttons, {name = name, text = text, x = "c", y = y, w = w, h = h})
end
function ButtonManager:removeButton(name)
	for i, v in ipairs(self.buttons) do
		if v.name == name then
			table.remove(self.buttons, i)
			return true
		end
	end
	return false
end
function ButtonManager:removeAllButtons()
	self.buttons = {}
end
------- Static functions -------
function ButtonManager.check(x, y, w, h, mx, my)
	w = w or 300*pixelscale
	h = h or 50*pixelscale
	x = x or (love.graphics.getWidth()-w)/2
	mx = mx or love.mouse.getX()
	my = my or love.mouse.getY()
	if x == "c" then
		x = (love.graphics.getWidth()-w)/2
		y = love.graphics.getHeight()/2 + y
	end
	if mx > x and mx < (x+w) and my > y and my < (y+h) then
		return true
	else
		return false
	end
end
function ButtonManager.drawBackButton(x, y)
	x = x or 0
	y = y or 0
	local w = 100*pixelscale
	local h = 50*pixelscale
	love.graphics.setColor(255,255,255)
	love.graphics.printf("< Back", x, y+(h-font:getHeight())/2, w, "center")
end
function ButtonManager.checkBackButton(mx, my, x, y)
	x = x or 0
	y = y or 0
	local w = 100*pixelscale
	local h = 50*pixelscale
	return ButtonManager.check(x, y, w, h, mx, my)
end

return ButtonManager