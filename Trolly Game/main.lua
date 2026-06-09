player = {}  
enemy = {}
enemyActive = false
spawnTimer = 0
spawnDelay = 0
death = {}
bullets = {}
bulletSpeed = 500
function love.conf(t)
    t.window.width = 720
    t.window.height = 720
    t.window.resizable = true
end
function love.load()
	    -- This is the coordinates where the player character will be rendered.
	player.x = 100   -- This sets the player at the middle of the screen based on the width of the game window. 
	player.y = 240 or 480  -- This sets the player at the middle of the screen based on the height of the game window. 
    player.facing = 1 -- 1 = right, -1 = left
    player.fireRate = 0.25 -- can shoot shoot 4 bullets per second
    player.fireCooldown = 0
	enemy.x = -100
	enemy.y = 0
        -- This calls the file named "purple.png" and puts it in the variable called player.img.
	player.img = love.graphics.newImage('purple.png')
	player.ground = player.y     -- This makes the character land on the plaform.
	player.speed = 200
	enemy.img = love.graphics.newImage('red.png')
	enemy.ground = enemy.y
	enemy.speed = 200
	enemyActive = false
	spawnTimer = 0
	spawnDelay = math.random(1, 3)
	gamestate = true
	death.img = love.graphics.newImage('death.jpg')
end

function love.update(dt)
	if gamestate == true then
		if love.keyboard.isDown('d') then
			-- This makes sure that the character doesn't go pass the game window's right edge.
			player.facing = 1
			if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
				player.x = player.x + (player.speed * dt)
			end
		elseif love.keyboard.isDown('a') then
			-- This makes sure that the character doesn't go pass the game window's left edge.
			player.facing = -1
			if player.x > 0 then 
				player.x = player.x - (player.speed * dt)
			end
		end
		if love.keyboard.isDown('w')then
			player.y = 240
		end
		if love.keyboard.isDown('s')then
			player.y = 480
		end
		
		
		-- spawn delay system
		if enemyActive == false then
			spawnTimer = spawnTimer + dt

			if spawnTimer >= spawnDelay then
				spawnTimer = 0
				spawnDelay = math.random(1, 3)

				enemy.x = love.graphics.getWidth()
				enemy.y = (math.random(1,2) == 1) and 240 or 480

				enemyActive = true
			end

			-- update cooldown based automatic timer
      		if player.fireCooldown > 0 then
      			player.fireCooldown = player.fireCooldown - dt
     		end
		end

		-- movement
		if enemyActive then
			enemy.x = enemy.x - enemy.speed * dt
		end

		-- reset
		if enemy.x < -50 then
			enemyActive = false
		end
		
		if checkCollision(player, enemy) then
    		gamestate = false
		end
		--if enemy.x == player.x then
		--	gamestate = false
		--end
		
    -- if checkCollision(bullet, enemy) then
    -- enemyActive = false
    -- end

    function bulletHitEnemy(bullet, enemy)
      return bullet.x < enemy.x + enemy.img:getWidth() and
      bullet.x + bullet.width > enemy.x and
      bullet.y < enemy.y + enemy.img:getHeight() and
      bullet.y + bullet.height > enemy.y
    end

    for i = #bullets, 1, - 1 do
      local bullet = bullets[i]

      if enemyActive and checkCollision(bullet, enemy) then
        enemyActive = false
        table.remove(bullets, i)
        -- move enemy off-screen immediately
        enemy.x = -100
        break
      end
    end

  end

  if love.keyboard.isDown('space') and player.fireCooldown <= 0 then
    -- Assuming player.x, player.y, and player.facing (1 for right, -1 for left) exist...
    local bullet = {
      x = player.x + player.img:getWidth() / 2,
      y = player.y,
      width = 8,
      height = 8,
      facing = player.facing or 1,
      speed = bulletSpeed
    }
    table.insert(bullets, bullet)
    player.fireCooldown = player.fireRate
  end

  -- Move bullets
  for i = #bullets, 1, - 1 do
    local bullet = bullets[i]

    bullet.x = bullet.x + bullet.speed * bullet.facing * dt

    -- Remove off-screen bullets
    if bullet.x < 0 or bullet.x > love.graphics.getWidth() then
      table.remove(bullets, i)
    end
  end

end

--issue here?

function checkCollision(a, b)
  local aw = a.width or a.img:getWidth()
  local ah = a.height or a.img:getHeight()

  local bw = b.width or b.img:getWidth()
  local bh = b.height or b.img:getHeight()

  return a.x < b.x + bw and
  a.x + aw > b.x and
  a.y < b.y + bh and
  a.y + ah > b.y
end

function love.draw()
	love.graphics.setColor(1, 1, 1)        -- This sets the platform color to white.
	love.graphics.rectangle("fill", 0 , 240 , love.graphics.getWidth(), 5)
	love.graphics.setColor(700, 700, 700)
	love.graphics.rectangle("fill", 0 , 480 , love.graphics.getWidth(), 5)
        -- The platform will now be drawn as a white rectangle while taking in the variables we declared above.
	love.graphics.draw(player.img, player.x, player.y, 0, 1, 1, 0, 32)
	love.graphics.draw(enemy.img, enemy.x, enemy.y, 0, 1, 1, 0, 32)
	love.graphics.print(tostring(enemyActive), 100,100)

	-- Draw bullets
  for _, bullet in ipairs(bullets) do
    love.graphics.circle(
      "fill",
      bullet.x,
      bullet.y,
      bullet.width,
      bullet.height
    )
  end
	
	if gamestate == false then
		love.graphics.print("Death", love .graphics.getWidth() / 2, love.graphics.getHeight()/2)
		love.graphics.draw(death.img,0, 100, 0, 1.12)

	end
end

