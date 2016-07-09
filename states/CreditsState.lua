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

local CreditsState = {}
local this = {}
CreditsState.this = this

local colors = {
	link = {25, 34, 154},
	white = {255, 255, 255}
}
function CreditsState.load()
	creditsFonts = {
		[1] = font,
		[2] = love.graphics.newFont("gfx/font.ttf",math.floor(30*pixelscale))
	}

	creditLines = {
		{text="Programming", size=2, wrap=2},
		{text="Joemag", size=1, wrap=4},
		
		{text="Level Design", size=2, wrap=2},
		{text="Joemag", size=1, wrap=2},
		{text="AnnynN", size=1, wrap=4},
		
		{text="Music", size=2, wrap=2},
		{text="Sunny Fields Galloping by OctoEntandre", size=1, wrap=1},
		{text="(Link)", size=1, link="http://www.newgrounds.com/audio/listen/525333", wrap=1, color="link"},
		{text="", size=1, wrap=2},
		{text="Monkeys Spinning Monkeys by Kevin MacLeod", size=1, wrap=1},
		{text="(Link)", size=1, link="http://incompetech.com/music/royalty-free/index.html?isrc=USUAN1400011", wrap=1, color="link"},
		{text="", size=1, wrap=4},
		
		{text="Font", size=2, wrap=2},
		{text="Kronika by Apostrophic Labs", size=1, wrap=1},
		{text="(Link)", size=1, link="http://www.dafont.com/kronika.font", wrap=1, color="link"},
		{text="", size=1, wrap=4},
		
		{text="Brushes", size=2, wrap=2},
		{text="My Grass Brushes by Archelerone", size=1, wrap=1},
		{text="(Link)", size=1, link="http://archeleron.deviantart.com/art/My-Grass-Brushes-82240003", wrap=1, color="link"},
		{text="", size=1, wrap=2},
		{text="Cloud Brushes ver.3 by cloud-no9", size=1, wrap=1},
		{text="(Link)", size=1, link="http://www.deviantart.com/art/Cloud-Brushes-ver-3-59000409", wrap=1, color="link"},
		{text="", size=1, wrap=4},
		
		{text="Assets", size=2, wrap=2},
		{text="Mobile Game GUI by GraphicBurger", size=1, wrap=1},
		{text="(Link)", size=1, link="http://graphicburger.com/mobile-game-gui/", wrap=1, color="link"},
		{text="", size=1, wrap=4},
		
		
		{text="", size=1, wrap=2},
		{image=love.graphics.newImage("gfx/love2d.png"), size=1, wrap=2, color="white", link="http://love2d.org/"},
		{text="", size=1, wrap=3},
		{image=love.graphics.newImage("gfx/oxyasa.png"), size=1, wrap=2, color="white", link="http://oxyasa.de/"},
		{text="", size=1, wrap=3},
	}
	
	creditlinks = {}
	creditHeight = 0
	
	
	if OS ~= "Android" then
		handcursor = love.mouse.getSystemCursor( "hand" )
		curcursor = ""
	end
end
function CreditsState.enter()
	this.scroll = ScrollManager.new({
		autoscrollspeed = 20,
		autoscrolltime = 3,
		offTop = game.offY,
		clickcallback = this.mouseclicked
	})
end
function CreditsState.update(dt)
	this.scroll:update(dt)
	if OS ~= "Android" then
		local cursorchanged = false
		if love.mouse.getY() > game.offY then
			for i, v in ipairs(creditlinks) do
				if ButtonManager.check((love.graphics.getWidth()-v.width)/2, v.y, v.width, v.height) then
					if not (curcursor == "hand") then
						curcursor = "hand"
						love.mouse.setCursor( handcursor )
					end
					cursorchanged = true
				end
			end
		end
		if not cursorchanged then
			if not (curcursor == "") then
				curcursor = ""
				love.mouse.setCursor()
			end
		end
	end
end

function CreditsState.draw()
	love.graphics.setColor(255,255,255,100)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	--love.graphics.printf(CREDITSTEXT, 10*pixelscale, game.offY+10*pixelscale, love.graphics.getWidth()-20*pixelscale)
	
	local cposy = -this.scroll.scrollY
	local startcposy = cposy
	creditlinks = {}
	for i, v in ipairs(creditLines) do
		local cfont
		if v.size and creditsFonts[v.size] then
			cfont = creditsFonts[v.size]
		else
			cfont = font
		end
		love.graphics.setFont(cfont)
		if v.color and (type(v.color) == "table" or (type(v.color) == "string" and colors[v.color])) then
			if type(v.color) == "table" then
				love.graphics.setColor(unpack(v.color))
			elseif type(v.color) == "string" then
				love.graphics.setColor(colors[v.color])
			end
		else
			love.graphics.setColor(0,0,0,255)
		end
		local _width, nlines, _height
		if v.text then
			love.graphics.printf(v.text, 10*pixelscale, cposy, love.graphics.getWidth()-20*pixelscale, "center")
			_width, nlines = cfont:getWrap(v.text, love.graphics.getWidth()-20*pixelscale)
			nlines = #nlines-1+(v.wrap or 1)
			_height = nlines*cfont:getHeight()
		end
		if v.image then
			local scale = math.min(math.min(love.graphics.getWidth()/v.image:getWidth(), love.graphics.getHeight()/v.image:getHeight()), pixelscale)
			_width = v.image:getWidth()* scale
			_height = v.image:getHeight()* scale
			love.graphics.draw(v.image, (love.graphics.getWidth()-_width)/2, cposy, 0, scale, scale)
		end
		
		--print(type(cfont))
		
		if v.link then
			table.insert(creditlinks, {link = v.link, y = cposy, width = _width, height = _height})
		end
		cposy = cposy + _height
		
		
	end
	creditHeight = cposy - startcposy
	
	love.graphics.setFont(font)
	this.scroll:drawScrollBar()
	this.scroll:setContentHeight(creditHeight)
	

	love.graphics.setColor(255,255,255,255)
	local barimg = RessourceManager.images.bar
	love.graphics.draw(barimg, 0, 0, 0, love.graphics.getWidth()/barimg:getWidth(), (50*pixelscale)/barimg:getHeight())
	ButtonManager.drawBackButton()
end
function CreditsState.wheelmoved(x, y)
	this.scroll:wheelmoved(x, y)
end
function CreditsState.mousepressed(x, y, button, istouch)
	this.scroll:mousepressed(x, y, button, istouch)
end
function this.mouseclicked(x, y, button)
	if y > game.offY then
		for i, v in ipairs(creditlinks) do
			if ButtonManager.check((love.graphics.getWidth()-v.width)/2, v.y, v.width, v.height) then
				if love.system and love.system.openURL then
					love.system.openURL(v.link)
					break
				end
			end
		end
	else
		if ButtonManager.checkBackButton(x, y) then
			creditsClickedOn = 0
			StateManager.setState("menu")
		end
	end
end
function CreditsState.mousereleased(x, y, button)
	this.scroll:mousereleased(x, y, button)
end
function CreditsState.keypressed(k)
	if k == "escape" then
		StateManager.setState("menu")
	end
end

StateManager.registerState("credits", CreditsState)
