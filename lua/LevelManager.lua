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

local LevelManager = {}
local this = LevelManager

function LevelManager.load()
	local contents
	if love.filesystem.isFile("levels.lua") then
		contents = love.filesystem.read("levels.lua")
	else
		contents = love.filesystem.read("levelsd.lua")
	end
	this.worlds = Tserial.unpack(contents)
end

function LevelManager.getWorldProgress(world, custom)
	if custom == "custom" then
		world = "cus_"..world
	end
	if custom == "myworld" or custom == "playmyworld" then
		return 0
	end
	local worldprog = 0
	if SaveManager.save.worlds and SaveManager.save.worlds[world] then
		for i, v in ipairs(SaveManager.save.worlds[world]) do
			if v then
				worldprog = worldprog + 1
			end
		end
	else
		worldprog = 0
	end
	return worldprog
end
function LevelManager.canPlayLevel(world, level, custom)
	if custom == "custom" then
		world = "cus_"..world
	end
	if custom == "myworld" or custom == "playmyworld" then
		return true
	end
	if SaveManager.save.worlds and 
	   SaveManager.save.worlds[world] and 
	   SaveManager.save.worlds[world][level] then
		return true
	end
	local notmade = 3
	for i = 1,level-1 do
		if (not SaveManager.save.worlds) or 
		   (not SaveManager.save.worlds[world]) or 
		   (not SaveManager.save.worlds[world][i]) then
			notmade = notmade-1
		end
	end
	if notmade > 0 then
		return true
	end
	return false
end
function LevelManager.setLevelSuccessed(world, level, custom)
	print(world, level, custom)
	if custom == "custom" then
		world = "cus_"..world
	end
	if custom == "myworld" or custom == "playmyworld" then
		return
	end
	if not SaveManager.save.worlds then
		SaveManager.save.worlds = {}
	end
	if not SaveManager.save.worlds[world] then
		SaveManager.save.worlds[world] = {}
	end
	SaveManager.save.worlds[world][level] = true
	SaveManager.saveGame()
end
function LevelManager.isLevelFinished(world, level, custom)
	if custom == "custom" then
		world = "cus_"..world
	end
	if custom == "myworld" or custom == "playmyworld" then
		return false
	end
	if SaveManager.save.worlds and 
	   SaveManager.save.worlds[world] and 
	   SaveManager.save.worlds[world][level] then
		return true
	else
		return false
	end
end
function LevelManager.isWorldFinished(world)
	local worldprog = LevelManager.getWorldProgress(world)
	local numlevels = LevelManager.getNumLevels(world)

	if worldprog >= numlevels then
		return true
	else
		return false
	end
end
function LevelManager.getWorld(world)
	return this.worlds[world]
end
function LevelManager.getNumLevels(world)
	return #this.worlds[world].levels
end
return LevelManager