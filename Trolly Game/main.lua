player = {}  
enemies = {}
spawnTimer = 0
spawnDelay = 0
numRails = 6
death = {}
enemyTypes = {}
rails = {}
bullets = {}
bulletSpeed = 500
padding = 40
function love.load()
	    -- This is the coordinates where the player character will be rendered.
	player.x = 100   -- This sets the player at the middle of the screen based on the width of the game window. 
	player.y = love.graphics.getHeight()/numRails  -- This sets the player at the middle of the screen based on the height of the game window and number of rails. 
	player.rail = 1
	player.img = love.graphics.newImage('assets/sprites/placeholder/Placeholder Trolley.png')
	player.ground = player.y     -- This makes the character land on the plaform.
	player.speed = 200
	player.facing = 1 -- 1 = right, -1 = left
	player.fireRate = 0.25 -- can shoot shoot 4 bullets per second
	player.fireCooldown = 0
	spawnTimer = 0
	spawnDelay = math.random(1, 3)
	gamestate = true
	death.img = love.graphics.newImage('death.jpg')
	enemyTypes = {
    	basic = {
        	image = love.graphics.newImage("red.png"),
        	speed = 200
    	},

    	dasher = {
        	image = love.graphics.newImage("dasher.png"),
        	speed = 50
    	},

    	shooter = {
        	image = love.graphics.newImage("assets/sprites/placeholder/Placeholder Enemy.png"),
        	speed = 25
    	}
	}
	railImg = love.graphics.newImage("assets/sprites/placeholder/Placeholder Tracks.png")
	local railHeight = getRailHeight()
	for i = 1, numRails do
		local rail = {
			y = padding + (i - 0.5) * railHeight,
			img = railImg
		}
		table.insert(rails, rail)
	end
	
	
end
function getRailHeight()
    return (love.graphics.getHeight() - padding * 2) / numRails
end
function love.keypressed(keyid, key, isrepeat)
	if gamestate == true then -- could be changed to represent more than 2 gamestates
		if key == 'w' then
			player.rail = ((player.rail + numRails - 2) % numRails) + 1 -- sub 1 and mod rails (offset due to 1 indexing)
		elseif key == 's' then
			player.rail = (player.rail % numRails) + 1 -- add 1 mod rails
		end
		if key == ('space') and player.fireCooldown <= 0 then
    		-- Assuming player.x, player.y, and player.facing (1 for right, -1 for left) exist...
    		local bullet = {
      			x = player.x + player.img:getWidth(),
      			y = player.y + player.img:getHeight() / 2,
      			width = 8,
      			height = 8,
      			facing = player.facing or 1,
      			speed = bulletSpeed
    		}
    		table.insert(bullets, bullet)
    		player.fireCooldown = player.fireRate
  		end
	end
end
function love.update(dt)
	--checks if the game is over every tick based on whether you died or not
	player.fireCooldown = player.fireCooldown - dt
	if player.fireCooldown < 0 then
    	player.fireCooldown = 0
	end
	if gamestate == true then		
		local railHeight = getRailHeight()
		player.y = padding + (player.rail - 0.5) * railHeight - player.img:getHeight() -- move player to rail's location
		for i = #bullets, 1, - 1 do
      		local bullet = bullets[i]
			for j = #enemies, 1, -1 do
        		local enemy = enemies[j]

        		if bulletHitEnemy(bullet, enemy) then
            		-- remove bullet
            		table.remove(bullets, i)

            		-- damage or remove enemy
            		enemy.hp = enemy.hp - 50

            		if enemy.hp <= 0 then
                		table.remove(enemies, j)
            		end

           	 		break -- stop checking other enemies for this bullet
       			end
    		end
    	end
		for i = #bullets, 1, - 1 do
    		local bullet = bullets[i]

    		bullet.x = bullet.x + bullet.speed * bullet.facing * dt

    		-- Remove off-screen bullets
    		if bullet.x < 0 or bullet.x > love.graphics.getWidth() then
      			table.remove(bullets, i)
    		end
  		end
		-- spawn delay and spawn system
		spawnTimer = spawnTimer + dt

		if spawnTimer >= spawnDelay then
    		spawnTimer = 0
    		spawnDelay = math.random(1, 3)
    		spawnEnemy()
		end

		-- movement
		for i, enemy in ipairs(enemies) do

    		if enemy.type == "basic" then
        		enemy.x = enemy.x - enemy.speed * dt

    		elseif enemy.type == "dasher" then
        		enemy.dashCooldown = enemy.dashCooldown - dt
				if enemy.dashCooldown <= 0 and enemy.dashTimer <= 0 then
					enemy.dashTimer = 0.6
					enemy.dashCooldown = math.random(2,5)
				end
				if enemy.dashTimer > 0 then
					enemy.dashTimer = enemy.dashTimer - dt
					enemy.x = enemy.x - (enemy.speed + 500) * dt
				else
					enemy.x = enemy.x - enemy.speed * dt
				end
    		elseif enemy.type == "shooter" then
        		enemy.x = enemy.x - enemy.speed * dt

        		-- shooting code later
    		end
		end
		-- reset
		for i = #enemies, 1, -1 do
    		if enemies[i].x < -50 then
        		table.remove(enemies, i)
    		end
		end
		--collision check
		for i, enemy in ipairs(enemies) do
        	if checkCollision(player, enemy) then
            	gamestate = false
        	end
    	end
	end
end

function spawnEnemy()

    local types = {"basic", "dasher", "shooter"}
    local enemyType = types[math.random(#types)]
	local rail = math.random(1, numRails)
    local data = enemyTypes[enemyType]
	print(enemyType)
	print(data)
	local railHeight = getRailHeight()
    local enemy = {
        type = enemyType,
        x = love.graphics.getWidth(),
        speed = data.speed,
		y = padding + (rail - 0.5) * railHeight - data.image:getHeight(),
        img = data.image,
		dash = true,
		bullet = true,
		dashTimer = 0,
    	dashCooldown = math.random(2,5),
		hp = 50
    }

    table.insert(enemies, enemy)
end
function bulletHitEnemy(bullet, enemy)
      return bullet.x < enemy.x + enemy.img:getWidth() and
      bullet.x + bullet.width > enemy.x and
      bullet.y < enemy.y + enemy.img:getHeight() and
      bullet.y + bullet.height > enemy.y
end
function checkCollision(a, b)
	--checks the enemy posistion versus the posistion of the player
    return a.x < b.x + b.img:getWidth() and
           a.x + a.img:getWidth() > b.x and
           a.y < b.y + b.img:getHeight() and
           a.y + a.img:getHeight() > b.y
end
function love.draw()
	love.graphics.setColor(1, 1, 1)        -- set rail color to white
	for i = 1, #rails do
    	local rail = rails[i]

    	local scaleX =
        	love.graphics.getWidth() / rail.img:getWidth()

    	love.graphics.draw(
        	rail.img,
        	0,
        	rail.y,
        	0,
        	scaleX,
        	1,
        	0,
        	rail.img:getHeight()
    	)
	end
        -- The platform will now be drawn as a white rectangle while taking in the variables we declared above.
	love.graphics.draw(player.img, player.x, player.y)
	for i, enemy in ipairs(enemies) do
        love.graphics.draw(enemy.img, enemy.x, enemy.y)
    end
	-- Draw bullets
  	for i, bullet in ipairs(bullets) do
    	love.graphics.circle(
      	"fill",
      	bullet.x,
      	bullet.y,
      	bullet.width,
      	bullet.height
    )
  end
	if gamestate == false then
		love.graphics.print("Death", love.graphics.getWidth() / 2, love.graphics.getHeight()/2)
		love.graphics.draw(death.img,0, 0, 0,love.graphics.getWidth() / death.img:getWidth(), love.graphics.getHeight() / death.img:getHeight())

	end
end

