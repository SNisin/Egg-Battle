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

local DownloadState = {}
local this = {}
DownloadState.this = this
function DownloadState.load()
this.downfile = nil
this.callbacks = {}
end
function DownloadState.enter(downloadURL, text, callbacks)
	this.downfile = DownloadManager.new(downloadURL)
	this.text = text
	this.callbacks = callbacks or {}
end
function DownloadState.update(dt)
	this.downfile:update()
	if this.downfile.success or this.downfile.error then
		local retcont = Tserial.unpack(this.downfile.content, true)
		if this.downfile.success and retcont then
			StateManager.retBack(retcont)
		else
			retcont = {
				error = true,
				errortype = "connenction error",
				errordesc = this.downfile.error
			}

			StateManager.retBack(retcont)
		end
	end
end
function DownloadState.draw()
	local lg = love.graphics

	local rw = math.min(lg.getWidth(), 300*pixelscale)
	local rh = math.min(lg.getHeight(), 150*pixelscale)
	
	local rx = (lg.getWidth()-rw)/2
	local ry = (lg.getHeight()-rh)/2

	lg.setColor(248,232,176)
	lg.rectangle("fill", rx, ry, rw, rh)
	lg.setColor(175,129,75)
	lg.rectangle("line", rx, ry, rw, rh)
	lg.setColor(0,0,0)
	_width, nlines = font:getWrap(this.text, rw-10*pixelscale)
	lg.printf(this.text, rx+5*pixelscale, (ry+rh/2)-font:getHeight()*nlines/2, rw-10*pixelscale, "center")

end
function DownloadState.threaderror(thread, errorstr )
	local retcont = {
				error = true,
				errortype = "threaderror",
				errordesc = "Error in Thread \""..thread.."\": "..errorstr
			}

			StateManager.retBack(retcont)
end
function DownloadState.mousepressed(x, y, button)
	if this.callbacks.mousepressed then
		this.callbacks.mousepressed(x, y, button)
	end
end
function DownloadState.mousereleased(x, y, button)
	if this.callbacks.mousereleased then
		this.callbacks.mousereleased(x, y, button)
	end
end
function DownloadState.keypressed(k)
	if this.callbacks.keypressed then
		this.callbacks.keypressed(k)
	end
end
StateManager.registerState("download", DownloadState)