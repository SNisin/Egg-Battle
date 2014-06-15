WonState = {}

function WonState.update(dt)
	-- Not called
end

function WonState.draw()
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(0,0,0,255)
	love.graphics.print("Level "..clvl.level.." succeeded", (love.graphics.getWidth()-font:getWidth("Level "..clvl.level.." succeeded"))/2+1, love.graphics.getHeight()/2-150*pixelscale+1)
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("Level "..clvl.level.." succeeded", (love.graphics.getWidth()-font:getWidth("Level "..clvl.level.." succeeded"))/2, love.graphics.getHeight()/2-150*pixelscale)
	
	drawButton(love.graphics.getHeight()/2-120*pixelscale, "Next level")
	drawButton(love.graphics.getHeight()/2, "Try again")
	drawButton(love.graphics.getHeight()/2+60*pixelscale, "Return to menu")
end

function WonState.mousepressed(x, y, button)
	if checkButton(nil, love.graphics.getHeight()/2-120*pixelscale) then
		if (clvl.level-1)%15 == 14 then
			game.state = "selectworld"
		else
			loadLevel(clvl.level+1)
		end
	end
	if checkButton(nil, love.graphics.getHeight()/2) then
		loadLevel(clvl.level)
	end
	if checkButton(nil, love.graphics.getHeight()/2+60*pixelscale) then
		game.state = "menu"
	end
end
