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

local function tableMerge(t1, t2)
    for k,v in pairs(t2) do
    	if type(v) == "table" then
    		if type(t1[k] or false) == "table" then
    			tableMerge(t1[k] or {}, t2[k] or {})
    		else
    			t1[k] = v
    		end
    	else
    		t1[k] = v
    	end
    end
    return t1
end

function SaveManager.loadGame()
	if love.filesystem.isFile("save.lua") then
		local content = love.filesystem.read("save.lua")
		local xsave = Tserial.unpack(content)

		tableMerge(SaveManager.save, xsave)

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