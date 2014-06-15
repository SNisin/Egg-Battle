MenuState = {}

function MenuState.update(dt)
	
end

function MenuState.draw()
	love.graphics.setColor(255,255,255,255)
	local logoscale  = math.min(love.graphics.getWidth()/(logo:getWidth()*1.2), love.graphics.getHeight()/(logo:getHeight()*4))
	local logoY = (love.graphics.getHeight()/2-60*pixelscale)/2-logo:getHeight()*logoscale/2
	love.graphics.draw(logo, (love.graphics.getWidth()-logo:getWidth()*logoscale)/2, logoY, 0, logoscale, logoscale)
	
	if save.crnt == 0 then
		drawButton(love.graphics.getHeight()/2-60*pixelscale, "Start Game")
	else
		--drawButton(love.graphics.getHeight()/3, "Continue Game")
		drawButton(love.graphics.getHeight()/2-60*pixelscale, "Continue Game")
	end
	drawButton(love.graphics.getHeight()/2+60*pixelscale, "Credits")
	drawButton(love.graphics.getHeight()/2+120*pixelscale, "Quit")
end

function MenuState.mousepressed(x, y, button)
	if save.crnt == 0 then
		if checkButton(nil, love.graphics.getHeight()/2-60*pixelscale) then
			loadLevel(1)
		end
	else
		--if checkButton(nil, love.graphics.getHeight()/3) then
		--	loadLevel(math.min(save.crnt+1, #levels))
		--end
		if checkButton(nil, love.graphics.getHeight()/2-60*pixelscale) then
			game.state = "selectworld"
		end
	end
	if checkButton(nil, love.graphics.getHeight()/2+60*pixelscale) then
		creditsScroll = -game.offY -10*pixelscale
		creditsAutoScroll = 0
		game.state = "credits"
	end
	if checkButton(nil, love.graphics.getHeight()/2+120*pixelscale) then
		love.event.quit()
	end

	
	if y > love.graphics.getHeight()-10 then
		--game.state = "editor"
	end
end

function MenuState.keypressed(k)
	if k == "x" then
		--game.state = "editor"
	elseif k == "escape" then
		love.event.quit()
	end
end