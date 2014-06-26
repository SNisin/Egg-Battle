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

local BackgroundManager = {}
local _clouds = {}
local _cloudspawntime = -5
local timet = 0
local _offY = 0
local function _updateGraphics()
	local backscale = math.max(love.graphics.getWidth()/backimg:getWidth(), love.graphics.getHeight()/backimg:getHeight())
	_clouds = {}
	cloudspawntime = -5
	table.insert(_clouds, {x=love.math.random(-500*backscale, love.graphics.getWidth()), y=love.math.random(10, 200)*backscale, type=love.math.random(1,#cloudsimg), speed=love.math.random(30, 160)*backscale, op=love.math.random(50,200)})
	table.insert(_clouds, {x=love.math.random(-500*backscale, love.graphics.getWidth()), y=love.math.random(10, 200)*backscale, type=love.math.random(1,#cloudsimg), speed=love.math.random(30, 160)*backscale, op=love.math.random(50,200)})
	table.insert(_clouds, {x=love.math.random(-500*backscale, love.graphics.getWidth()), y=love.math.random(10, 200)*backscale, type=love.math.random(1,#cloudsimg), speed=love.math.random(30, 160)*backscale, op=love.math.random(50,200)})
	table.insert(_clouds, {x=love.math.random(-500*backscale, love.graphics.getWidth()), y=love.math.random(10, 200)*backscale, type=love.math.random(1,#cloudsimg), speed=love.math.random(30, 160)*backscale, op=love.math.random(50,200)})
	table.insert(_clouds, {x=love.math.random(-500*backscale, love.graphics.getWidth()), y=love.math.random(10, 200)*backscale, type=love.math.random(1,#cloudsimg), speed=love.math.random(30, 160)*backscale, op=love.math.random(50,200)})
end
function BackgroundManager.load()
	_updateGraphics()
end
function BackgroundManager.update(dt)
	dt = math.min(dt, 0.1)
	local backscale = math.max(love.graphics.getWidth()/backimg:getWidth(), love.graphics.getHeight()/backimg:getHeight())
	timet = timet + dt
	for i, v in ipairs(_clouds) do
		v.x = v.x-v.speed*dt
		if v.x<0-cloudsimg[v.type]:getWidth()*backscale then
			table.remove(_clouds, i)
		end
	end
	if timet > cloudspawntime+5 then
		cloudspawntime = timet
		table.insert(_clouds, {x=love.graphics.getWidth(), y=love.math.random(10, 200)*backscale, type=love.math.random(1,#cloudsimg), speed=love.math.random(30, 160)*backscale, op=love.math.random(50,200)})
	end
end
function BackgroundManager.draw(offY)
	offY = offY or _offY or 0
	love.graphics.setColor(255,255,255,255)
	local backscale = math.max(love.graphics.getWidth()/backimg:getWidth(), love.graphics.getHeight()/backimg:getHeight())
	love.graphics.draw(backimg, 0, -(backimg:getHeight()*backscale-love.graphics.getHeight())+offY*0.3, 0, backscale, backscale)
	for i, v in ipairs(_clouds) do
		love.graphics.setColor(255, 255, 255, v.op)
		love.graphics.draw(cloudsimg[v.type], v.x, v.y + offY*0.1, 0, backscale, backscale)
	end
	_offY = 0
end
function BackgroundManager.resize()
	_updateGraphics()
end
function BackgroundManager.setOffY(offY)
	_offY = offY
end
return BackgroundManager