function init_zombie_list()
	return {}
end

function create_zombie(zombie_list, x, y, hp, speed, color)
	local z = HC.circle(x, y, 16)
	z.health = hp
	z.speed = speed
	z.targ_x = x
	z.targ_y = y
	z.color = color
	table.insert(zombie_list, z)
	return z
end

function process_zombies(zombie_list, dt)
	for i,z in ipairs(zombie_list) do
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

function zombie_hurt(z, zombie_list, i, dmg)
	z.health = z.health - dmg
	z.color = {125, 125, 0, 255}
	if z.health <= 0 then
		HC.remove(z)
		table.remove(zombie_list, i)
	end
end

function draw_zombies(zombie_list)
	for i,z in ipairs(zombie_list) do
		draw_zombie(z)
	end
end

function draw_zombie(z)
	love.graphics.setColor(z.color[1], z.color[2], z.color[3], z.color[4])
	z:draw('line')
end