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