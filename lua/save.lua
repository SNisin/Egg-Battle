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

function load_game()
	if love.filesystem.isFile("save.lua") then
		local content = love.filesystem.read("save.lua")
		save = Tserial.unpack(content)
	else
		save = {
			worlds = {
				--[1] = {true,true,true,true,true,true,true,true,true,true,true,true,true,true,true}
			},
			crnt = 0
		}
		save_game()
	end
end
function save_game()
	print("saved!")
	local content = Tserial.pack(save)
	love.filesystem.write("save.lua", content)
end