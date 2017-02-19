--Initiate collider
HC = require 'lib/HardonCollider'
require 'player'
require 'zombie'

local player = nil
local zombie_director = nil
local projectiles = {}

local gamestate = 0 --0 = not running, 1 = yay running

function startGame()
	player = new_player()
	zombie_director = init_zombie_director()
	gamestate = 1
end

function endGame()
	player = remove_player(player)
	gamestate = 0
end

function get_player()
	return player
end

function love.mousepressed(x, y, button)
	if player ~= nil then
		player_mousetrigger(player, button, 1, x, y)
	end
end

function love.mousereleased(x, y, button)
	if player ~= nil then
		player_mousetrigger(player, button, 0, x, y)
	end
end

function love.wheelmoved(x, y)
	if y > 0 then
		player.currgun = player.currgun + 1
		if player.currgun > #player.weapons then
			player.currgun = 1
		end
	elseif y < 0 then
		player.currgun = player.currgun -1
		if player.currgun < 1 then
			player.currgun = #player.weapons
		end
	end
end

function love.keypressed(key)
	if player ~= nil then
		player_keytrigger(player, key, 1)
	end
end

function love.keyreleased(key)
	if player ~= nil then
		player_keytrigger(player, key, 0)
	end
end

function init_projectile(ox, oy, dmg, vel, penetration)
	local p = HC.point(ox, oy)
	p.damage = dmg
	p.velocity = vel
	p.angle = 0
	p.dx = 0 --direction x
	p.dy = 0 --direction y
	p.ox = ox
	p.oy = oy
	p.trailx = 0
	p.traily = 0
	p.penetration = penetration or 0

	return p
end

function shoot_projectile(p, angle)
	table.insert(projectiles, p)
	p.angle = angle
	p.dx = p.velocity * math.cos(p.angle)
	p.dy = p.velocity * math.sin(p.angle)
end

function projectile_hit(p, other)
	if p.penetration > 0 then
		p.penetration = p.penetration - 1
		p.damage = p.damage * 0.8
		return 0
	end
	return 1
end

function processGame(dt)
	if gamestate ~= 1 then return end --Gamestate is not set to "running"

	if player ~= nil then
		player_process(player, dt)
	end
	process_zombies(zombie_director, dt)
	for i,p in ipairs(projectiles) do
		local p_x,p_y = p:center()
		local dist = math.dist(p.ox, p.oy, p_x, p_y)
		p.trailx = p.dx*(math.min(dist/p.velocity, 0.1))
		p.traily = p.dy*(math.min(dist/p.velocity, 0.1))
		p:move(p.dx*dt, p.dy*dt)

		p_x,p_y = p:center() --Update p_x and p_y because of p:move
		if p_x < -200 or p_x > love.graphics.getWidth() + 200 or p_y < -200 or p_y > love.graphics.getHeight() + 200 then
			table.remove(projectiles, i) -- remove bullet from actor list
			HC.remove(p) -- remove bullet from HC
		end
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
					if projectile_hit(p, other) == 1 then
						table.remove(projectiles, i) -- remove bullet from actor list
						HC.remove(p) -- remove bullet from HC
					end
				end
			end
		end
	end

	for i,z in ipairs(zombie_director) do
		local candidates = HC.neighbors(z)
		for other in pairs(candidates) do
			local collides, dx, dy = z:collidesWith(other)
			if collides and other ~= nil and z ~= nil then
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
		love.graphics.print("WEAPON: " .. player.weapons[player.currgun].name, 0, love.graphics.getHeight()-28)
		love.graphics.print(player.curmag .. "/" .. player.weapons[player.currgun].mag, love.graphics.getWidth()-74, love.graphics.getHeight()-28)
	end
	love.graphics.print("TIMER: " .. math.floor(zombie_director.timer), 130, 0)
	love.graphics.print("|WAVE: " .. zombie_director.wave, love.graphics.getWidth()/2-64, 0)
	love.graphics.print("|ZOMBIES: " .. #zombie_director, love.graphics.getWidth()/2+64, 0)
end