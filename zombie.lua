function init_zombie_director()
	local z = {}
	z.timer = 10
	z.wave = 0
	z.wave_period = 30 --A single wave lasts 30 seconds
	z.grace_period = 15 --Time until next wave
	z.zombie_per_second = 2 --Spawn a zombie every second
	z.spawn_timer = 0 --timer itself
	z.state = 0 --What state of director are we in? 0 = Grace Period, 1 = Active Wave
	-- z.types = {
	-- 	{
	-- 		name = 'slow'
	-- 		basehealth = 10
	-- 		basespeed = 50
	-- 		attack = 5
	-- 		attackspeed = 1
	-- 		color = {0, 125, 0, 255}
	-- 		scale = 16
	-- 		wave = 0
	-- 		spawnchance = 1
	-- 	}
	-- 	{
	-- 		name = 'fast'
	-- 		basehealth = 3
	-- 		basespeed = 125
	-- 		attack = 2
	-- 		attackspeed = 0.3
	-- 		color = {125, 125, 0, 255}
	-- 		scale = 14
	-- 		wave = 4
	-- 		spawnchance = 0.2
	-- 	}
	-- }
	return z
end

function create_zombie(zombie_director, type, x, y)
	local z = HC.circle(x, y, type.scale)
	z.health = type.basehealth
	z.speed = type.basespeed
	z.color = type.color
	z.targ_x = x
	z.targ_y = y
	table.insert(zombie_director, z)
	return z
end

function process_zombies(zombie_director, dt)
	zombie_director.timer = zombie_director.timer - dt
	if zombie_director.timer <= 0 then
		if zombie_director.state == 0 then
			zombie_director.wave = zombie_director.wave + 1 --Increase wave
			zombie_director.zombie_per_second = math.max(zombie_director.zombie_per_second * 0.8, 0.3) --Make it harder
			zombie_director.state = 1
			zombie_director.timer = zombie_director.wave_period
		elseif zombie_director.state == 1 then
			zombie_director.state = 0
			zombie_director.spawn_timer = 0
			zombie_director.timer = zombie_director.grace_period
		end
	end

	if zombie_director.state == 1 then
		zombie_director.spawn_timer = zombie_director.spawn_timer + dt
		if zombie_director.spawn_timer > zombie_director.zombie_per_second then
			zombie_director.spawn_timer = 0
			local player = get_player()
			if player ~= nil then
				local player_x,player_y = player:center()
				local angle = math.pi * 2 * love.math.random()
				local x = player_x + 300 * math.cos(angle)
				local y = player_y + 300 * math.sin(angle)

				local wave = zombie_director.wave
				local hp = 5 * math.clamp(wave/5, 1, 10)
				local speed = 50 * math.clamp(wave/5, 1, 10)
				create_zombie(zombie_director, {scale = 16, basespeed = speed, basehealth = hp, color = {0, 125, 0, 255}}, x, y)
			end
		end
	end

	--Zombie AI
	for i,z in ipairs(zombie_director) do
		local player = get_player()
		if player ~= nil then
			local player_x,player_y = player:center()
			z.targ_x = player_x
			z.targ_y = player_y
		end
		local x,y = z:center()
		local dx = z.targ_x - x
		local dy = z.targ_y - y
		local dm = math.sqrt(dx * dx + dy * dy)
		if dm == 0 then dm = 1 end
		local mx = dt * z.speed * dx / dm
		local my = dt * z.speed * dy / dm
		if dx < 0 and mx < dx then mx = dx end
		if dx > 0 and mx > dx then mx = dx end
		if dy < 0 and my < dy then my = dy end
		if dy > 0 and my > dy then my = dy end
		z:move(mx, my)
	end
end

function zombie_hurt(z, zombie_director, i, dmg)
	z.health = z.health - dmg
	if z.health <= 0 then
		zombie_death(z, zombie_director, i)
	end
end

function zombie_death(z, zombie_director, i)
	zombie_remove(z, zombie_director, i)
end

function zombie_remove(z, zombie_director, i)
	HC.remove(z)
	table.remove(zombie_director, i)
end

function draw_zombies(zombie_director)
	for i,z in ipairs(zombie_director) do
		draw_zombie(z)
	end
end

function draw_zombie(z)
	love.graphics.setColor(z.color[1], z.color[2], z.color[3], z.color[4])
	z:draw('line')
end