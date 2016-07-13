require 'game'
require 'lib/math'

function love.load()
	love.graphics.setBackgroundColor(50, 40, 40)
	startGame()
end

function love.update(dt)
	processGame(dt)
end

function love.draw()
	drawGame()
end