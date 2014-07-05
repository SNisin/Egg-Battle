local downloadURL, downid = ...

local content = {}
local download_channel = love.thread.getChannel(downid)

local http = require("socket.http")
local ltn12 = require("ltn12")	

function downloadToString(dllink)
	local lsink = ltn12.sink.table(content)
	local f, e, h = http.request{
		url = dllink,
		sink = lsink
	}
	return f, e, h
end

local f, e, h = downloadToString(downloadURL)
download_channel:push({id="content", value=table.concat(content)})
print("finished")

if e == 200 then
	download_channel:supply({id = "success"})
elseif (f == nil and e) or e ~= 200 then
	download_channel:supply({id = "error", desc = e})
else
	download_channel:supply({id = "error", desc = "unknown"})
end