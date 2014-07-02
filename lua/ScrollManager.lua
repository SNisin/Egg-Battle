local ScrollManager = {}
ScrollManager.__index = ScrollManager

function ScrollManager.new(opts)
	local t = {}
	setmetatable(t,ScrollManager)

	t.scrollY = starty or 0							-- Current scroll position
	t.autoScrollSpeed = opts.autoscrollspeed or 0	-- Autoscroll speed
	t.autoScrollTime = opts.autoscrolltime or 0		-- time to wait to autoscroll
	t.autoScrollTimer = 0
	t.clickedY = opts.starty or 0					-- the screen y position where clicked
	t.isClicked = false								-- if clicked
	t.clickedScroll = 0								-- the scroll position when clicked
	t.notSelect = true								-- if it should not count as clicked when releasing
	t.contentHeight = opts.contentHeight or 0
	t.offTop = opts.offTop or 0
	t.offBottom = opts.offBottom or 0
	t.clickCallback = opts.clickcallback or function() end

	t.scrollVelocity = 0

	return t
end
function ScrollManager:update(dt)
	local oldscroll = self.scrollY
	if self.autoScrollTimer <= 0 and self.autoScrollSpeed > 0 then
		self.scrollY = self.scrollY+self.autoScrollSpeed*dt 	-- Autoscroll
	else
		self.autoScrollTimer = self.autoScrollTimer -dt 		-- update timer
	end
	if love.mouse.isDown("l") and self.isClicked then
		self.scrollY = self.clickedScroll + (self.clickedY - love.mouse.getY())  --scroll if clicked, based on mouse position

		self.scrollVelocity = (self.scrollY - oldscroll)/dt
	else
		self.isClicked = false
		self.scrollY = self.scrollY + self.scrollVelocity * dt
		if math.abs(self.scrollVelocity) > 1 then
			self.scrollVelocity = self.scrollVelocity * math.pow(0.02, dt)
		else
			self.scrollVelocity = 0
		end
	end

	if math.abs(self.clickedY-love.mouse.getY()) > 30*pixelscale then
		self.notSelect = true
	end

	local scrollmin, scrollmax = self:getMinMax()


	if self.scrollY > scrollmax then		-- Don't scroll to far down
		self.scrollY = scrollmax
	end
	if self.scrollY < scrollmin then		-- Don't scroll to far up, has to be called after the check for down
		self.scrollY = scrollmin			-- because if contentheight is smaller than displayheight
	end


end

function ScrollManager:mousepressed(x, y, button)
	self.scrollVelocity = 0
	if button == "l" then
		self.isClicked = true
		self.clickedY = y 
		self.clickedScroll = self.scrollY
		self.notSelect = false
	elseif button == "wu" then
		self.scrollY = self.scrollY - 50*pixelscale
		
	elseif button == "wd" then
		self.scrollY = self.scrollY + 50*pixelscale
	end
	self.autoScrollTimer = self.autoScrollTime
end

function ScrollManager:mousereleased(x, y, button)

	if button == "l" then
		if self.isClicked then
			self.isClicked = false
			self.autoScrollTimer = self.autoScrollTime
			if not self.notSelect then
				self.clickCallback(x, y, button)
			end
		end
	end
end

function ScrollManager:setContentHeight(contentHeight)
	assert(type(contentHeight)=="number", "number expected")
	self.contentHeight = contentHeight
end
function ScrollManager:drawScrollBar(  )
	local scrollmin, scrollmax = self:getMinMax()
	if scrollmax > scrollmin then
		local displayheight = love.graphics.getHeight() - self.offTop - self.offBottom
		local barheight = (displayheight / self.contentHeight) * displayheight
		barheight =  math.max(barheight, 10*pixelscale)
		local spacing = 5*pixelscale
		local barpos = (self.scrollY-scrollmin) / (scrollmax-scrollmin) * (displayheight-barheight-spacing*2) + self.offTop + spacing
		love.graphics.setColor(0,0,0,150)
		love.graphics.rectangle("fill", love.graphics.getWidth()-15*pixelscale, barpos, 5*pixelscale, barheight)
	end
end
function ScrollManager:getMinMax()
	local min = -self.offTop
	local max = self.contentHeight - love.graphics.getHeight() + self.offBottom
	return min, max
end

return ScrollManager