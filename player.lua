function new_player()
	player = HC.circle(love.graphics.getWidth()/2, love.graphics.getHeight()/2, 16)
	player.health = 100
	player.speed = 75
	player.trigger = 0
	player.gunTimer = 0
	player.curmag = 0

	--Weapons available
	player.weapons = {
		{
			name = 'pistol',
			dmg = 5,
			automatic = false,
			fired = false,
			velocity = 500,
			firerate = 0.1,
			pellets = 1,
			spread = 0.1,
			smartspread = 0,
			mag = 12,
			reloadtime = 0.5,
			penetration = 0
		},
		{
			name = 'smg',
			dmg = 2,
			automatic = true,
			fired = false,
			velocity = 500,
			firerate = 0.1,
			pellets = 1,
			spread = 0.2,
			smartspread = 0,
			mag = 30,
			reloadtime = 0.8,
			penetration = 0
		},
		{
			name = 'shotgun',
			dmg = 3,
			automatic = false,
			fired = false,
			velocity = 500,
			firerate = 0.6,
			pellets = 6,
			spread = 0.6,
			smartspread = 1,
			mag = 6,
			reloadtime = 1,
			penetration = 0
		},
		{
			name = 'rifle',
			dmg = 20,
			automatic = false,
			fired = false,
			velocity = 1000,
			firerate = 2,
			pellets = 1,
			spread = 0,
			smartspread = 0,
			mag = 8,
			reloadtime = 3,
			penetration = 2 --every penetration is 80% of the current damage
		}
	}
	--Weaponlist END
	player.currgun = 1
	return player
end

function remove_player(player)
	HC.remove(player)
	player = nil
	return player
end

function player_process(player, dt)
	--Movement code below
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

	--Firing code below
	player.gunTimer = math.max(player.gunTimer - dt, 0)
	if player.weapons[player.currgun] ~= nil then
		if player.curmag <= 0 then
			player.curmag = player.weapons[player.currgun].mag
			player.gunTimer = player.weapons[player.currgun].reloadtime
			return
		end
		if player.trigger == 1 then
			if player.gunTimer > 0 then return end --Not ready to fire yet
			if player.weapons[player.currgun].automatic == false and player.weapons[player.currgun].fired == true then return end --Only one shot for non-auto weps

			local player_x,player_y = player:center()

			player.weapons[player.currgun].fired = true
			player.gunTimer = player.gunTimer + player.weapons[player.currgun].firerate
			player.curmag = player.curmag - 1

			local mouse_x, mouse_y = love.mouse.getX(), love.mouse.getY()
			--create 'pellets'
			local spread = player.weapons[player.currgun].spread
			for i = 1, player.weapons[player.currgun].pellets do
				local finalspread = 0
				if player.weapons[player.currgun].smartspread == 1 then
					finalspread = (i / player.weapons[player.currgun].pellets - 0.5) * spread
				else
					finalspread = (math.random() - 0.5) * spread
				end
				local p = init_projectile(player_x, player_y, player.weapons[player.currgun].dmg, player.weapons[player.currgun].velocity, player.weapons[player.currgun].penetration)
				local angle = math.atan2((mouse_y - player_y), (mouse_x - player_x))

				shoot_projectile(p, angle + finalspread)
			end
		else
			player.weapons[player.currgun].fired = false
		end
	end
end

function player_mousetrigger(player, button, toggle, x, y)
	if button == 1 then
		player.trigger = toggle
	end
end

function player_keytrigger(player, button, toggle)
	if toggle == 1 then
		if button == '1' then
			player.currgun = 1
			player.curmag = 0
		elseif button == '2' then
			player.currgun = 2
			player.curmag = 0
		elseif button == '3' then
			player.currgun = 3
			player.curmag = 0
		elseif button == '4' then
			player.currgun = 4
			player.curmag = 0
		end
	end

	if button == 'lctrl' then
		player.trigger = toggle
	end
end

function player_hurt(dmg)
	player.health = player.health - dmg
	if player.health <= 0 then
		endGame()
	end
end