local message, downid = ...

local ipURL = "http://eggbattle.bplaced.net/errorReport.php"

local content = {}
local download_channel = love.thread.getChannel(downid)


local http = require("socket.http")
local ltn12 = require("ltn12")	

function url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str	
end

function sendReprt(url, msg)
    local req_body = "errormessage="..url_encode(msg)
    local headers = {
	    ["Content-Type"] = "application/x-www-form-urlencoded",
	    ["Content-Length"] = #req_body
	}
	
	local client, code, headers, status = http.request{
		url=url, 
		sink=ltn12.sink.table(content),
		method="POST", 
		headers=headers, 
		source=ltn12.source.string(req_body)
	}
    return client, code, headers, status
end

local f, e, h = sendReprt(ipURL, message)
--download_channel:push({id="content", value=table.concat(content)})
print(table.concat(content))

if e == 200 then
	download_channel:supply({id = "success"})
elseif (f == nil and e) or e ~= 200 then
	download_channel:supply({id = "error", desc = e})
else
	download_channel:supply({id = "error", desc = "unknown"})
end