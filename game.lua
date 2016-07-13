--Initiate collider
HC = require 'lib/hardoncollider'
require 'zombie'

local player = nil
local zombie_director = nil
local projectiles = {}

function startGame()
	player = HC.circle(love.graphics.getWidth()/2, love.graphics.getHeight()/2, 16)
	player.health = 100
	player.speed = 75
	zombie_director = init_zombie_director()
end

function endGame()
	HC.remove(player)
	player = nil
end

function get_player()
	return player
end

function love.mousepressed(x, y, button)
	print(x, y, button)
	if button == 1 then
		if player == nil then return end

		local player_x,player_y = player:center()

		local p = HC.point(player_x, player_y)
		p.damage = 5
		p.angle = math.atan2((y - player_y), (x - player_x))
		p.dx = 300 * math.cos(p.angle)
		p.dy = 300 * math.sin(p.angle)
		p.ox = player_x
		p.oy = player_y

		table.insert(projectiles, p)
	end

	-- if button == 2 then
	-- 	create_zombie(zombie_director, x, y, 10, 50, {0, 125, 0, 255})
	-- end
end

function processGame(dt)
	if player ~= nil then
		local pdx, pdy = 0,0
		if love.keyboard.isDown("d") then --right
			pdx = (player.speed * dt)
		end
		if love.keyboard.isDown("a") then --left
			pdx = -(player.speed * dt)
		end
		if love.keyboard.isDown("s") then --down 
			pdy = (player.speed * dt)
		end
		if love.keyboard.isDown("w") then --up
			pdy = -(player.speed * dt)
		end
		player:move(pdx,pdy)
	end
	process_zombies(zombie_director, dt)
	for i,p in ipairs(projectiles) do
		local p_x,p_y = p:center()
		local dist = math.dist(p.ox, p.oy, p_x, p_y)
		p.trailx = p.dx*(math.min(dist/300, 0.1))
		p.traily = p.dy*(math.min(dist/300, 0.1))
		p:move(p.dx*dt, p.dy*dt)
	end
	check_collisions()
end

function check_collisions()
	for i,p in ipairs(projectiles) do
		local collisions = HC.collisions(p)
		for u,z in ipairs(zombie_director) do
			for other, dif in pairs(collisions) do
				if z == other then
					zombie_hurt(z, zombie_director, u, p.damage)
					HC.remove(p) -- remove bullet from HC
					table.remove(projectiles, i) -- remove bullet from actor list
				end
			end
		end
	end

	for i,z in ipairs(zombie_director) do
		local candidates = HC.neighbors(z)
		for other in pairs(candidates) do
			local collides, dx, dy = z:collidesWith(other)
			if collides then
				other:move(-dx*0.5, -dy*0.5)
				z:move(dx*0.5, dy*0.5)
			end
		end
		if player ~= nil then
			local collides, dx, dy = z:collidesWith(player)
			if collides then
				player_hurt(2)
			end
		end
	end
end

function player_hurt(dmg)
	player.health = player.health - dmg
	if player.health <= 0 then
		endGame()
	end
end

function drawGame()
	love.graphics.setColor(255, 255, 255)
	if player ~= nil then
		player:draw('fill')
	end

	love.graphics.setColor(255, 255, 0)
	love.graphics.setLineWidth(2)
	for i,p in ipairs(projectiles) do
		local x,y = p:center()
		love.graphics.line(x, y, x - p.trailx, y - p.traily)
	end

	draw_zombies(zombie_director)

	-- for i,e in ipairs(particles) do
	-- 	love.graphics.setColor(e.color[1], e.color[2], e.color[3], e.color[4])
	-- 	love.graphics.circle('fill', e.x, e.y, e.radius)
	-- end

	--HUD
	love.graphics.setColor(0, 200, 0, 255)
	love.graphics.setNewFont(24)
	if player ~= nil then
		love.graphics.print("HP: " .. player.health, 0, 0)
	end
	love.graphics.print("TIMER: " .. math.floor(zombie_director.timer), love.graphics.getWidth()/2-58, 0)
	love.graphics.print("WAVE: " .. zombie_director.wave, love.graphics.getWidth()-128, 0)
end