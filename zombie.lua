function process_zombies(zombies, dt)
	for i,z in ipairs(zombies) do
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

function zombie_hurt(z, zombies, i, dmg)
	z.health = z.health - dmg
	z.color = {125, 125, 0, 255}
	if z.health <= 0 then
		HC.remove(z)
		table.remove(zombies, i)
	end
end

function draw_zombies(zombies)
	for i,z in ipairs(zombies) do
		draw_zombie(z)
	end
end

function draw_zombie(z)
	love.graphics.setColor(z.color[1], z.color[2], z.color[3], z.color[4])
	z:draw('line')
end