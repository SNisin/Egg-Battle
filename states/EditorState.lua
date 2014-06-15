EditorState = {}

function EditorState.load()
	edit = {
		world={
			{0,0,0,0,0},
			{0,0,0,0,0},
			{0,0,0,0,0},
			{0,0,0,0,0},
			{0,0,0,0,0},
			{0,0,0,0,0}
		},
		taps=1,
		level=#levels+1,
		fsel=0
	}
	editmessage = ""
	editmessageop = 0
end

function EditorState.update(dt)
	if editmessageop > 0 then
		editmessageop = editmessageop - 128*dt
		if editmessageop < 0 then editmessageop = 0 end
	end
end

function EditorState.draw()
	love.graphics.setColor(0,0,0,100)
	for y =1, #edit.world do
		love.graphics.rectangle("fill", 0, (y-1)*game.tileh+game.offY, love.graphics.getWidth(), 2)
	end
	for x =1, #edit.world[1] do
		love.graphics.rectangle("fill", (x-1)*game.tilew, game.offY, 2, love.graphics.getHeight())
	end
	
	love.graphics.setColor(255,255,255,255)
	for y,v in ipairs(edit.world) do
		for x,v2 in ipairs(v) do
			if eggs[v2] then
				love.graphics.draw(eggs[v2], (x-1)*game.tilew+game.eggofX, (y-1)*game.tileh+game.eggofY +game.offY, 0, game.scale, game.scale)
			end
		end
	end
	love.graphics.setColor(255,255,255,150)
	love.graphics.draw(barimg, 0, 0, 0, love.graphics.getWidth()/barimg:getWidth(), (50*pixelscale)/barimg:getHeight())
	
	love.graphics.setColor(0,0,0,255)
	love.graphics.print("Level: "..edit.level, math.floor(21*pixelscale), (game.offY-font:getHeight())/2+1)
	if edit.fsel == 1 then
		love.graphics.setColor(255,255,0,255)
	else
		love.graphics.setColor(255,255,255,255)
	end
	love.graphics.print("Level: "..edit.level, math.floor(20*pixelscale), (game.offY-font:getHeight())/2)
	
	love.graphics.setColor(0,0,0,255)
	love.graphics.print("Moves: "..edit.taps, math.floor(61*pixelscale) + font:getWidth("Level: "..edit.level), (game.offY-font:getHeight())/2+1)
	if edit.fsel == 2 then
		love.graphics.setColor(255,255,0,255)
	else
		love.graphics.setColor(255,255,255,255)
	end
	love.graphics.print("Moves: "..edit.taps, math.floor(60*pixelscale) + font:getWidth("Level: "..edit.level), (game.offY-font:getHeight())/2)
	
	love.graphics.setColor(0,0,0,255)
	love.graphics.print("Save!", love.graphics.getWidth() - font:getWidth("Save!") - 19*pixelscale, (game.offY-font:getHeight())/2)
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("Save!", love.graphics.getWidth() - font:getWidth("Save!") - 20*pixelscale, (game.offY-font:getHeight())/2)
	
	love.graphics.setColor(0,0,0,255)
	love.graphics.print("Try", love.graphics.getWidth() - font:getWidth("Try") - font:getWidth("Save!") - 39*pixelscale, (game.offY-font:getHeight())/2)
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("Try", love.graphics.getWidth() - font:getWidth("Try") - font:getWidth("Save!") - 40*pixelscale, (game.offY-font:getHeight())/2)
	
	love.graphics.setColor(0,0,0,editmessageop)
	love.graphics.print(editmessage, (love.graphics.getWidth() - font:getWidth(editmessage))/2+1, (game.offY-font:getHeight())/2+1)
	love.graphics.setColor(255,255,255,editmessageop)
	love.graphics.print(editmessage, (love.graphics.getWidth() - font:getWidth(editmessage))/2, (game.offY-font:getHeight())/2)
end

function EditorState.mousepressed(mx, my, button)
	--if my > love.graphics.getHeight()-10 then
	--	EditorState.keypressed("return")
	--	return
	--end
	local x = math.floor(mx/game.tilew)+1
	local y = math.floor((my-game.offY)/game.tileh)+1
	if edit.world[y] and edit.world[y][x] then
		if button == "wu" then
			edit.world[y][x] = edit.world[y][x] + 1
			if edit.world[y][x]>#eggs then edit.world[y][x] = #eggs end
		elseif button == "wd" then
			edit.world[y][x] = edit.world[y][x] - 1
			if edit.world[y][x]<0 then edit.world[y][x] = 0 end
		end
		if button == "l" then
			edit.world[y][x] = edit.world[y][x] + 1
			if edit.world[y][x]>#eggs then edit.world[y][x] = 0 end
		end
		if button == "r" then
			edit.world[y][x] = edit.world[y][x] - 1
			if edit.world[y][x]<0 then edit.world[y][x] = #eggs end
		end
		
	end
	edit.fsel = 0
	if checkButton(math.floor(20*pixelscale), 0, font:getWidth("Level: "..edit.level), game.offY) then
		edit.olevel = edit.level
		if button == "wu" then
			edit.level = math.max(0, edit.level+1)
			changeedlevel()
		elseif button == "wd" then
			edit.level = math.max(0, edit.level-1)
			changeedlevel()
		else
			edit.fsel = 1
			love.keyboard.setTextInput(true)
		end
		
	elseif checkButton(math.floor(60*pixelscale) + font:getWidth("Level: "..edit.level), 0, font:getWidth("Moves: "..edit.taps), game.offY) then
		if button == "wu" then
			edit.taps = math.max(0, edit.taps+1)
		elseif button == "wd" then
			edit.taps = math.max(0, edit.taps-1)
		else
			edit.fsel = 2
			love.keyboard.setTextInput(true)
		end
	elseif checkButton(love.graphics.getWidth() - font:getWidth("Save!") - 20*pixelscale, 0, font:getWidth("Save!"), game.offY) then
		EditorState.keypressed(" ")
	elseif checkButton(love.graphics.getWidth() - font:getWidth("Save!") - font:getWidth("Try") - 40*pixelscale, 0, font:getWidth("Try"), game.offY) then
		EditorState.keypressed("return")
	else
		love.keyboard.setTextInput(false)
	end
end

function EditorState.keypressed(k)
	local clevel = false
	edit.olevel = edit.level
	if k == "backspace" then
		if edit.fsel == 1 then
			if string.len(tostring(edit.level))<2 then
				edit.level = 0
				clevel = true
			else
				edit.level = tonumber(string.sub(tostring(edit.level), 1, string.len(tostring(edit.level))-1))
				clevel = true
			end
		elseif edit.fsel == 2 then
			if string.len(tostring(edit.taps))<2 then
				edit.taps = 0
			else
				edit.taps = tonumber(string.sub(tostring(edit.taps), 1, string.len(tostring(edit.taps))-1))
			end
		end
	elseif k == "return" then
		love.keyboard.setTextInput(false)
		clvl.world = table.copy(edit.world, true)
		clvl.level = edit.level
		clvl.taps = edit.taps
		clvl.projectiles = {}
		game.state = "game"
		game.editt = true
	elseif k == " " then
		if edit.level > 0 then
			levels[edit.level]={}
			levels[edit.level].world = table.copy(edit.world, true)
			levels[edit.level].taps = edit.taps
		end
		if love.filesystem.isFile("levels.lua") then
			local con = love.filesystem.read("levels.lua")
			love.filesystem.write(os.date('%d_%m_%y %H_%M_%S.lua'), con)
			love.filesystem.remove("levels.lua")
		end
		
		local data = Tserial.pack(levels)
		love.filesystem.write("levels.lua", data)
		
		editmessage = "Saved!"
		editmessageop = 255
	elseif tonumber(k) then
		if edit.fsel == 1 then
			edit.level = tonumber(edit.level..k)
			clevel = true
		elseif edit.fsel == 2 then
			edit.taps = tonumber(edit.taps..k)
		end
	end
	if clevel then
		changeedlevel()
	end
end


function changeedlevel()
	if edit.olevel > 0 and edit.olevel<=#levels+1 and not checkempty() then
		levels[edit.olevel] = {}
		levels[edit.olevel].world = table.copy(edit.world, true)
		levels[edit.olevel].taps = edit.taps
	else
		levels[edit.olevel] = nil
	end
	if edit.level > #levels+1 then
		edit.level = #levels+1
	end
	if levels[edit.level] then
		edit.world = table.copy(levels[edit.level].world, true)
		edit.taps = levels[edit.level].taps
	else
		edit.world={
				{0,0,0,0,0},
				{0,0,0,0,0},
				{0,0,0,0,0},
				{0,0,0,0,0},
				{0,0,0,0,0},
				{0,0,0,0,0}
			}
		edit.taps = 1
	end
end

function checkempty(wld)
	wld = wld or edit.world
	for y,v in ipairs(wld) do
		for x,v2 in ipairs(v) do
			if eggs[v2] then
				return false
			end
		end
	end
	return true
end