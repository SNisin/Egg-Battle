function checkButton(x, y, w, h)
	if w == nil then
		w = 300*pixelscale
	end
	if h == nil then
		h = 50*pixelscale
	end
	if x == nil then
		x = (love.graphics.getWidth()-w)/2
	end
	local mx = love.mouse.getX()
	local my = love.mouse.getY()
	if mx > x and mx < (x+w) and my > y and my < (y+h) then
		return true
	else
		return false
	end
end
function drawButton(y, text, x, w)
	w = w or 300*pixelscale
	x = x or (love.graphics.getWidth()-w)/2
	
	--if checkButton((love.graphics.getWidth()-w)/2, y, w, 50) then
	--	love.graphics.setColor(220,255,255,255)
	--else
		love.graphics.setColor(255,255,255,255)
	--end
	rounded_rectangle("fill", x, y, w, 50*pixelscale, 10*pixelscale)
	love.graphics.setColor(0,100,0,255)
	rounded_rectangle("line", x, y, w, 50*pixelscale, 10*pixelscale)
	love.graphics.setColor(0,0,0,255)
	love.graphics.print(text, x+(w-font:getWidth(text))/2, y+25*pixelscale-font:getHeight()/2)
end
--[[function rounded_rectangle(mode, x, y, w, h, r, n)
  n = n or 20  -- Number of points in the polygon.
  if n % 4 > 0 then n = n + 4 - (n % 4) end  -- Include multiples of 90 degrees.
  local pts, c, d, i = {}, {x + w / 2, y + h / 2}, {w / 2 - r, r - h / 2}, 0
  while i < n do
    local a = i * 2 * math.pi / n
    local p = {r * math.cos(a), r * math.sin(a)}
    for j = 1, 2 do
      table.insert(pts, c[j] + d[j] + p[j])
      if p[j] * d[j] <= 0 and (p[1] * d[2] < p[2] * d[1]) then
        d[j] = d[j] * -1
        i = i - 1
      end
    end
    i = i + 1
  end
  love.graphics.polygon(mode, pts)
end]]
rounded_rectangle_buffer = {}
function rounded_rectangle(mode, x, y, width, height, xround, yround)
	yround = yround or xround
	local canvas
	local points = {}
	local tI, hP = table.insert, .5*math.pi
	if rounded_rectangle_buffer[mode.." "..width.." "..height.." "..xround.." "..yround] then
		canvas = rounded_rectangle_buffer[mode.." "..width.." "..height.." "..xround.." "..yround]
	else
		local precision = (xround + yround) *0.5
		if xround > width*.5 then xround = width*.5 end
		if yround > height*.5 then yround = height*.5 end
		local X1, Y1, X2, Y2 = xround+5, yround+5, width - xround+5, height - yround+5
		local sin, cos = math.sin, math.cos
		for i = 0, precision, 0.1 do
			local a = (i/precision-1)*hP
			tI(points, X2 + xround*cos(a))
			tI(points, Y1 + yround*sin(a))
		end
		for i = 0, precision do
			local a = (i/precision)*hP
			tI(points, X2 + xround*cos(a))
			tI(points, Y2 + yround*sin(a))
		end
		for i = 0, precision do
			local a = (i/precision+1)*hP
			tI(points, X1 + xround*cos(a))
			tI(points, Y2 + yround*sin(a))
		end
		for i = 0, precision do
			local a = (i/precision+2)*hP
			tI(points, X1 + xround*cos(a))
			tI(points, Y1 + yround*sin(a))
		end
		canvas = love.graphics.newCanvas(width+10, height+10)
		local olr , olg, olb, ola = love.graphics.getColor()
		love.graphics.setCanvas(canvas)
		love.graphics.setColor(255 , 255, 255)
		love.graphics.polygon(mode, unpack(points))
		love.graphics.setCanvas()
		love.graphics.setColor(olr , olg, olb, ola)
		rounded_rectangle_buffer[mode.." "..width.." "..height.." "..xround.." "..yround] = canvas
	end
	love.graphics.draw(canvas, x-5, y-5)
end
