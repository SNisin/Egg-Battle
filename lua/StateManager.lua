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

local StateManager = {}
local _allStates = {}		-- list of all States available
local _currentStates = {}	-- list of loaded States
local _alwaysState			-- State which will be called allways


function StateManager.registerCallbacks()
	local callbacks = {"focus","keypressed","keyreleased","mousefocus","mousepressed","mousereleased",
						"textinput","threaderror","update","visible","gamepadaxis","gamepadpressed",
						"gamepadreleased","joystickadded","joystickaxis","joystickhat","joystickpressed",
						"joystickreleased","joystickremoved", "directorydropped", "filedropped", 
						"textedited", "touchmoved", "touchpressed", "touchreleased", "wheelmoved"} -- Callbacks called for last _currentState
	local callbacksAll = {"draw", "resize", "lowmemory"}	-- Callbacks called for all _currentStates
	local callbacksVAll = {"load" ,"quit"} -- Callbacks called for all States
	
	for i, v in ipairs(callbacks) do
		love[v] = function(...) 
			if _alwaysState and _allStates[_alwaysState][v] then
				_allStates[_alwaysState][v](...)
			end
			if #_currentStates > 0 and _allStates[_currentStates[#_currentStates]][v] then
				_allStates[_currentStates[#_currentStates]][v](...)
			else
				--error("no State")
			end
		end
	end
	for i, v in ipairs(callbacksAll) do
		love[v] = function(...) 
			if _alwaysState and _allStates[_alwaysState][v] then
				_allStates[_alwaysState][v](...)
			end
			for ii, vv in ipairs(_currentStates) do
				if _allStates[vv][v] then
					_allStates[vv][v](...)
				end
			end
		end
	end
	for i, v in ipairs(callbacksVAll) do
		love[v] = function(...) 
			local ret
			if _allStates[_alwaysState] and _allStates[_alwaysState][v] then
				ret = ret or _allStates[_alwaysState][v](...)
			end
			for ii, vv in pairs(_allStates) do
				if vv[v] and not(ii == _alwaysState) then
					ret = ret or vv[v](...)
				end
			end
			return ret -- return for love.quit
		end
	end
end

local function callEnterCallback(name, ...)
	if _allStates[name].enter then
		_allStates[name].enter(...)
	end
end

function StateManager.registerState(name, stateTable)
	_allStates[name] = stateTable
end

function StateManager.setAlwaysState(name, ...)
	_alwaysState = name
	callEnterCallback(name, ...)
end

function StateManager.setState(name, ...)
	if not _allStates[name] then
		error("State '"..name.."' doesn't exist.")
	end
	_currentStates = {[1] = name}
	callEnterCallback(name, ...)
end

function StateManager.addState(name, ...)
	table.insert(_currentStates, name)
	callEnterCallback(name, ...)
end

function StateManager.changeState(name, ...)
	_currentStates[#_currentStates] = name
	callEnterCallback(name, ...)
end

function StateManager.retBack(...)
	table.remove(_currentStates, #_currentStates)
	local laststate = _currentStates[#_currentStates]
	if _allStates[laststate].returned then
		_allStates[laststate].returned(...)
	end
end


return StateManager