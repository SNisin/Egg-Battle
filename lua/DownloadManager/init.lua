local DOWNLOADMANAGER_PATH = DOWNLOADMANAGER_PATH or ({...})[1]:gsub("[%.\\/]init$", ""):gsub("%.", "/")

local DownloadManager = {}

function DownloadManager.new(downloadURL)
	local o = {}
	setmetatable(o, DownloadManager)
	DownloadManager.__index = DownloadManager
	
	local downid = "download "..downloadURL.." "..math.random()
	
	--private
	o.thread = love.thread.newThread(DOWNLOADMANAGER_PATH.."/downloadThread.lua")
	o.channel = love.thread.getChannel(downid)

	--public
	o.downloadURL = downloadURL

	o.success = false
	o.error = nil
	o.thread:start(o.downloadURL, downid)
	return o
end
function DownloadManager:update()
	local value = self.channel:pop()
	while value do
		if type(value) == "table" then
			if value.id == "content" then
				self.content = value.value
			elseif value.id == "success" then
				self.success = true
			elseif value.id == "error" then
				self.error = value.desc
				print("Error: ".. self.error)
			end
		end
		value = self.channel:pop()
	end
end

return DownloadManager