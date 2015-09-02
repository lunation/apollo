canvas = {}

-- Width and height
setmetatable(canvas,{__index=function(t,k)
	if k=="width" then
		return window.canvas_element.width
	elseif k=="height" then
		return window.canvas_element.height
	end
end})

function canvas.setFill(fill)
	window.canvas_context2d.fillStyle = fill
end

function canvas.fillRect(...)
	window.canvas_context2d:fillRect(...)
end




local n = 0

function window:frame_callback(dt)
	--Clear the screen.
	window.canvas_context2d:clearRect(0,0,window.canvas_element.width,window.canvas_element.height)

	canvas.setFill("blue")

	local inc = math.pi/10
	local mx = canvas.width/2
	local my = canvas.height/2

	for i=0,19 do
		local d = 200*math.cos(n+inc*i*6)
		canvas.fillRect(mx+math.sin(n+inc*i)*d,my+math.cos(n+inc*i)*d,20,20)
	end

	n=n+dt
end