require 'game'
require 'lib/math'

function love.load()
	love.graphics.setBackgroundColor(40, 50, 40)
	startGame()
end

function love.update(dt)
	processGame(dt)
end

function love.draw()
	drawGame()
end