local SaveManager = {}
local this = {}

SaveManager.save = {
	worlds = {  --list of played worlds. true for levels that are succeeded.
		--[1] = {true,true,true,true,true,true,true,true,true,true,true,true,true,true,true}
	},
	myworlds = {}, --list of played custom worlds. true for levels that are succeeded.
	crnt = 0, -- 0, if no level played yet.
	mute = false, -- sound mute?
	saveformat = 1, -- current save format id, may be useful later for updating format.
	version = GAMEVERSION, -- current game version, may be useful later.
	versionCreated = GAMEVERSION  -- game version when this save file was created, may be useful later.
}
SaveManager.loaded = false

function SaveManager.loadGame()
	if love.filesystem.isFile("save.lua") then
		local content = love.filesystem.read("save.lua")
		local xsave = Tserial.unpack(content)

		table.merge(SaveManager.save, xsave)
		SaveManager.save.version = GAMEVERSION
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