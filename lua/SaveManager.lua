local SaveManager = {}
local this = {}

SaveManager.save = {
	worlds = {
		--[1] = {true,true,true,true,true,true,true,true,true,true,true,true,true,true,true}
	},
	crnt = 0,
	mute = false
}
SaveManager.loaded = false

function SaveManager.loadGame()
	if love.filesystem.isFile("save.lua") then
		local content = love.filesystem.read("save.lua")
		local xsave = Tserial.unpack(content)

		table.merge(SaveManager.save, xsave)

	else
		SaveManager.saveGame()
	end
	SaveManager.loaded = true
end
function SaveManager.saveGame()
	local content = Tserial.pack(SaveManager.save)
	love.filesystem.write("save.lua", content)
end

return SaveManager