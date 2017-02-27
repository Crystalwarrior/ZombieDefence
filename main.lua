require 'game'
require 'lib/math'

function love.load()
	local font = love.graphics.newImageFont("imagefont.png",
		" abcdefghijklmnopqrstuvwxyz" ..
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
		"123456789.,!?-+/():;%&`'*#=[]\"")
	--love.graphics.setFont(font)
	love.graphics.setBackgroundColor(40, 50, 40)

	love.mouse.setVisible(false)
	love.mouse.setGrabbed(true)

	startGame()
end

function love.update(dt)
	processGame(dt)
end

function love.draw()
	drawGame()
end