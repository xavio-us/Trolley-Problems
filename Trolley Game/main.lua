player = {}  
enemies = {}
collectibles = {}
score = 0
spawnTimer = 0
spawnDelay = 0
numRails = 6
sprites = {}
gamestates = {["alive"] = 1, ["dead"] = 2, ["menu"] = 3, ["paused"] = 4}
gamestate = gamestates.menu -- you should start on the menu
enemyTypes = {}
rails = {}
bullets = {}
rockets = {}
lasers = {}
bulletSpeed = 500
rocketSpeed = 450
laserSpeed = 700
rocketWarningDuration = 1.4
laserWarningDuration = 1.0
rocketSpawnTimer = 0
rocketSpawnDelay = 0
laserSpawnTimer = 0
laserSpawnDelay = 0
padding = 40
pauseFont = love.graphics.newFont(32) -- size 32 default font
highlighted = 0 -- which option in a menu is highlighted, 0 means none, 1 is first

function Width()
	return love.graphics.getWidth()
end

function Height()
	return love.graphics.getHeight()
end

function generateRail(i,j)
	local tile = {
		x=(j-1)*railImg:getWidth(),
		y=padding + (i - 0.5) * getRailHeight() + math.random(-2,2)
	}

 	-- 3% chance of becoming a barrier
    if math.random() < 0.01 then
        tile.img = barrierImg
        tile.type = "barrier"
    else
        tile.img = railImg
        tile.type = "rail"
    end

    return tile
end

function resetBgTiles()
	backgroundTiles = {}
	backgroundTiles.a = {
		x = 0, y = 0
	}
	backgroundTiles.b = {
		x = Width(), y = 0
	}
end

function love.load()

	-- reset everything
	enemies = {}
	collectibles = {}
	spawnTimer = 0
	spawnDelay = 0
	rails = {}
	resetBgTiles()
	bullets = {}
	score = 0

	    -- This is the coordinates where the player character will be rendered.
	player.x = 100   -- This sets the player at the middle of the screen based on the width of the game window. 
	player.y = love.graphics.getHeight()/numRails  -- This sets the player at the middle of the screen based on the height of the game window and number of rails. 
	player.rail = 1
	player.animTimer = 50
	player.bounceDirection = -2
	player.img = love.graphics.newImage('assets/sprites/trolley.png')
	player.ground = player.y     -- This makes the character land on the plaform.
	player.speed = 200
	player.facing = 1 -- 1 = right, -1 = left
	player.fireRate = 0.25 -- can shoot shoot 4 bullets per second
	player.fireCooldown = 0
	spawnTimer = 0
	spawnDelay = math.random(1, 3)
	rockets = {}
	rocketSpawnTimer = 0
	rocketSpawnDelay = math.random(4, 7)
	lasers = {}
	laserSpawnTimer = 0
	laserSpawnDelay = math.random(5, 9)
	gamestate = gamestates.menu -- change later when main menu added
	sprites.background = love.graphics.newImage('assets/sprites/background_texture.png')
	sprites.death = love.graphics.newImage('assets/sprites/placeholder/death.jpg')
	sprites.start = love.graphics.newImage('assets/sprites/start.png')
	sprites.paused = love.graphics.newImage('assets/sprites/placeholder/paused.png')
	sprites.warning = love.graphics.newImage('assets/sprites/warning_placeholder.png')
	sprites.warningLaser = love.graphics.newImage('assets/sprites/warning_placeholder_laser.png')
	sprites.rocket = love.graphics.newImage('assets/sprites/rocket.png')

	enemyTypes = {
    	basic = {
        	image = love.graphics.newImage("assets/sprites/placeholder/red.png"),
        	speed = 200
    	},

    	dasher = {
        	image = love.graphics.newImage("assets/sprites/placeholder/dasher.png"),
        	speed = 50
    	},

    	shooter = {
        	image = love.graphics.newImage("assets/sprites/placeholder/Placeholder Enemy.png"),
        	speed = 25
    	}
	}
	collectibleTypes = {
    	coin = {
      		image = love.graphics.newImage('assets/sprites/coin.png'),
      		speed = 200,
      		collectibleScore = 10
    	},
    	people = {
      		image = love.graphics.newImage('assets/sprites/people.png'),
      		speed = 300,
      		collectibleScore = 300
    	}
  	}
	railImg = love.graphics.newImage("assets/sprites/rail_tile.png")
	barrierImg = love.graphics.newImage("assets/sprites/barrier.png")
	for i=1, numRails do
		rails[i] = {}
		for j=1, math.ceil(Width()/railImg:getWidth()) + 1 do
			rails[i][j] = generateRail(i,j)
		end
	end
end
function indexMod(a, b, c) -- value, increment, mod
	return ((a + b + c - 1) % c) + 1
end
function getRailHeight()
    return (Height() - padding * 2) / numRails
end
function love.keypressed(keyid, key, isrepeat)
	if gamestate == gamestates.alive then
		if key == 'w' then
			if player.rail > 1 then
				player.rail = player.rail - 1
			end
		elseif key == 's' then
			if player.rail < numRails then
				player.rail = player.rail + 1
			end
		elseif key == 'escape' then
			gamestate = gamestates.paused
			highlighted = 1
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
	elseif gamestate == gamestates.paused then
		if key == 'escape' then
			gamestate = gamestates.alive
		elseif key == 'w' then
			highlighted = indexMod(highlighted, -1, 3) -- num options is 3 right now, change if diff.
		elseif key == 's' then
			highlighted = indexMod(highlighted, 1, 3)
		elseif key == 'space' then
			if highlighted == 1 then
				gamestate = gamestates.alive
			elseif highlighted == 2 then
				gamestate = gamestates.menu
				love.load()
				-- maybe reset game here? i dont know
			elseif highlighted == 3 then
				-- save data?
				love.event.quit(0) -- quit gracefully
			end
		end
	end
end
function love.update(dt)
	if gamestate == gamestates.menu then
		if love.mouse.isDown(1) then
			x, y = love.mouse.getPosition()
			if (x > Width()/2 - sprites.start:getWidth()/2 and x < Width()/2 + sprites.start:getWidth()/2) and (y > Height()/2 - sprites.start:getHeight()/2 and y < Height()/2 + sprites.start:getHeight()/2) then
				gamestate = gamestates.alive
				love.graphics.setBackgroundColor(0,0,0)
			end
		end
	elseif gamestate == gamestates.paused then
		x, y = love.mouse.getPosition()
		for i=1,3 do
			if (x > .40*Width() and x < .60*Width() and y >.40*Height()+.10*Height()*i and y < .40*Height()+.10*Height()*i+pauseFont:getHeight()) then
				highlighted = i
				if love.mouse.isDown(1) then
					if highlighted == 1 then
						gamestate = gamestates.alive
					elseif highlighted == 2 then
						gamestate = gamestates.Menu
						love.load()
					elseif highlighted == 3 then
						love.event.quit(0)
					end
				end
				break
			end
		end
	elseif gamestate == gamestates.alive then

		if (backgroundTiles.b.x == 0) then -- animate background tiles
			resetBgTiles()
		else
			backgroundTiles.a.x = backgroundTiles.a.x - 2
			backgroundTiles.b.x = backgroundTiles.b.x - 2
		end

	--checks if the game is over every tick based on whether you died or not
		score = score + dt
		player.fireCooldown = player.fireCooldown - dt
		if player.fireCooldown < 0 then
			player.fireCooldown = 0
		end		
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
    		if bullet.x < 0 or bullet.x > Width() then
      			table.remove(bullets, i)
    		end
  		end
		-- spawn delay and spawn system
		spawnTimer = spawnTimer + dt

		if spawnTimer >= spawnDelay then
    		spawnTimer = 0
    		spawnDelay = math.random(1, 3)
    		spawnEnemy()
			spawnCollectible()
		end

		-- rocket warning and active rocket spawning
		rocketSpawnTimer = rocketSpawnTimer + dt
		if rocketSpawnTimer >= rocketSpawnDelay then
			rocketSpawnTimer = 0
			rocketSpawnDelay = math.random(4, 7)
			spawnRocketWarning()
		end

		-- laser warning and active laser spawning
		laserSpawnTimer = laserSpawnTimer + dt
		if laserSpawnTimer >= laserSpawnDelay then
			laserSpawnTimer = 0
			laserSpawnDelay = math.random(5, 9)
			spawnLaserWarning()
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

		-- rocket warning countdown and active rocket movement
		for i = #rockets, 1, -1 do
			local rocket = rockets[i]
			if rocket.state == "warning" then
				rocket.timer = rocket.timer - dt
				rocket.flashTimer = rocket.flashTimer + dt
				if rocket.timer <= 0 then
					rocket.state = "active"
				end
			else
				rocket.x = rocket.x - rocket.speed * dt
			end

			if rocket.x + rocket.width < 0 then
				table.remove(rockets, i)
			elseif rocket.state == "active" and checkCollision(player, rocket) then
				gamestate = gamestates.dead
			end
		end

		-- laser warning countdown and active laser timing
		for i = #lasers, 1, -1 do
			local laser = lasers[i]
			if laser.state == "warning" then
				laser.timer = laser.timer - dt
				laser.flashTimer = laser.flashTimer + dt
				if laser.timer <= 0 then
					laser.state = "active"
					laser.activeTimer = laser.activeDuration
				end
			else
				laser.activeTimer = laser.activeTimer - dt
				if laser.activeTimer <= 0 then
					table.remove(lasers, i)
				end
			end

			if laser.state == "active" and player.rail == laser.rail then
				gamestate = gamestates.dead
			end
		end
		--collision check
		for i, enemy in ipairs(enemies) do
        	if checkCollision(player, enemy) then
            	gamestate = gamestates.dead
        	end
    	end
		for i = 1, #rails do
    		for j = 1, #rails[i] do
        		local tile = rails[i][j]

        		if tile.type == "barrier" then
            		local barrier = {
                		x = tile.x,
                		y = tile.y - tile.img:getHeight(),
                		img = tile.img
            		}

            		if checkCollision(player, barrier) then
                		gamestate = gamestates.dead
            		end
        		end
    		end
		end
		-- rail tile movement
		for i = 1, #rails do
			for j = 1, #rails[i] do
				local rail = rails[i][j]
				rail.x = rail.x - 2
			end
			if -rails[i][1].x >= rails[i][1].img:getWidth() then
				table.remove(rails[i], 1)
				rails[i][#rails[i]+1] = generateRail(i,#rails[i]+1)
			end
		end
	end
		--COLLECTIBLES
    -- movement
    for i, collectible in ipairs(collectibles) do

      if collectible.type == "coin" then
        collectible.x = collectible.x - collectible.speed * dt
        -- sound effect code later
      elseif collectible.type == "people" then
        collectible.x = collectible.x - collectible.speed * dt
        -- sound effect code later
      end
    end
    -- reset
    for i = #collectibles, 1, - 1 do
      if collectibles[i].x < - 50 then
        table.remove(collectibles, i)
      end
    end
    --collision check
    for i, collectible in ipairs(collectibles) do
      if checkCollision(player, collectible) then
        score = score + collectible.collectibleScore
        print(score)
        table.remove(collectibles, i)
      end
    end


	-- if player.animTimer > 0 then -- This controls the trolley's "bouncing" animation on the tracks
	-- 	player.animTimer = player.animTimer - 1
	-- else
	-- 	player.animTimer = 50
	-- 	player.x = player.x + player.bounceDirection
	-- 	player.bounceDirection = -player.bounceDirection
	-- end
	-- -----------------
end
function spawnCollectible()
  local types = {"coin", "people"}
  local collectibleType = types[math.random(#types)]
  local rail = math.random(1, numRails)
  local data = collectibleTypes[collectibleType]

  local railHeight = getRailHeight()
  local collectible = {
    type = collectibleType,
    x = Width(),
    speed = data.speed,
    y = padding + (rail - 0.5) * railHeight - data.image:getHeight(),
    img = data.image,
    collectibleScore = data.collectibleScore
  }

  table.insert(collectibles, collectible)
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
        x = Width(),
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

function spawnRocketWarning()
    local rail = math.random(1, numRails)
    local railHeight = getRailHeight()
    local warningWidth = sprites.warning:getWidth()
    local warningHeight = sprites.warning:getHeight()
    local rocket = {
        x = Width() - warningWidth - 10,
        y = padding + (rail - 0.5) * railHeight - warningHeight,
        width = warningWidth,
        height = warningHeight,
        speed = rocketSpeed,
        state = "warning",
        timer = rocketWarningDuration,
        warningImg = sprites.warning,
        img = sprites.rocket,
        rail = rail,
        flashTimer = 0
    }
    table.insert(rockets, rocket)
end

function spawnLaserWarning()
    local rail = math.random(1, numRails)
    local railHeight = getRailHeight()
    local warningWidth = sprites.warningLaser:getWidth()
    local warningHeight = sprites.warningLaser:getHeight()
    local laserHeight = railHeight - 8
    local laser = {
        warningX = Width() - warningWidth - 10,
        warningY = padding + (rail - 0.5) * railHeight - warningHeight,
        x = 0,
        y = padding + (rail - 0.5) * railHeight - laserHeight,
        width = Width(),
        height = laserHeight,
        state = "warning",
        timer = laserWarningDuration,
        activeDuration = 0.2,
        activeTimer = 0,
        img = sprites.warningLaser,
        rail = rail,
        flashTimer = 0
    }
    table.insert(lasers, laser)
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

	if gamestate == gamestates.menu then
		love.graphics.setBackgroundColor(150/255, 200/255, 1)
		love.graphics.print(Width(), 0, 0)
		love.graphics.print(Height(), 0, 20)
		love.graphics.draw(sprites.start, Width()/2 - sprites.start:getWidth()/2, Height()/2 - sprites.start:getHeight()/2)
	end

	-- love.graphics.print(gamestate, love.graphics.getWidth() / 2, love.graphics.getHeight()/2)
	if gamestate == gamestates.dead then
		love.graphics.print("Death", Width() / 2, Height()/2 - 100)
		love.graphics.draw(sprites.death,0, 0, 0,Width() / sprites.death:getWidth(), Height() / sprites.death:getHeight())
	end
	if gamestate == gamestates.alive or gamestate == gamestates.paused then
		love.graphics.draw(sprites.background, backgroundTiles.a.x, backgroundTiles.a.y, 0, 1.5, 1.5)
		love.graphics.draw(sprites.background, backgroundTiles.b.x, backgroundTiles.b.y, 0, 1.5, 1.5)
		love.graphics.setColor(1, 1, 1)        -- set rail color to white
	
		for i = 1, #rails do
			for j = 1, #rails[i] do
				local rail = rails[i][j]
				local scale = 1

				love.graphics.draw(
					rail.img,
					rail.x,
					rail.y,
					0,
					scale,
					scale,
					0,
					rail.img:getHeight()
				)
			end
		end
		--draw score text
    	-- Get window dimensions
    	local windowWidth, windowHeight = love.graphics.getDimensions()
   		-- Get current font height
    	local font = love.graphics.getFont()
    	local fontHeight = font:getHeight()
    	-- Print at X=10 and calculate bottom edge using Y
    	-- The +0.5 helps with pixel-perfect alignment (optional)
    	love.graphics.print("Score: " .. score, 10, windowHeight - fontHeight - 5)

			-- The platform will now be drawn as a white rectangle while taking in the variables we declared above.
		love.graphics.draw(player.img, player.x, player.y, 0, player.drawScale, player.drawScale)
		
		for i, enemy in ipairs(enemies) do
			love.graphics.draw(enemy.img, enemy.x, enemy.y)
		end

		for i, rocket in ipairs(rockets) do
			if rocket.state == "warning" then
				local flashInterval = 0.15
				if math.floor(rocket.flashTimer / flashInterval) % 2 == 0 then
					love.graphics.setColor(1, 1, 1)
					love.graphics.draw(rocket.warningImg, rocket.x, rocket.y)
				end
			else
				love.graphics.setColor(1, 1, 1)
				love.graphics.draw(rocket.img, rocket.x, rocket.y, 0, 0.17, 0.17)
			end
		end

		for i, laser in ipairs(lasers) do
			if laser.state == "warning" then
				local flashInterval = 0.15
				if math.floor(laser.flashTimer / flashInterval) % 2 == 0 then
					love.graphics.setColor(1, 1, 1)
					love.graphics.draw(laser.img, laser.warningX, laser.warningY)
				end
			else
				love.graphics.setColor(1, 0, 0)
				love.graphics.rectangle("fill", laser.x, laser.y, laser.width, laser.height)
			end
		end
		love.graphics.setColor(1, 1, 1)		
		for i, collectible in ipairs(collectibles) do
      		love.graphics.draw(collectible.img, collectible.x, collectible.y)
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
	end
	if gamestate == gamestates.paused then
		love.graphics.setColor(0,0,0,0.85) -- high alpha black rectangle over the whole screen
		love.graphics.rectangle("fill",0,0,Width(),Height())

		love.graphics.setColor(1,1,1) -- regular white (for now)

		love.graphics.draw(sprites.paused, Width()/2 - sprites.paused:getWidth()/2, .25*Height() - sprites.paused:getHeight()/2)
		love.graphics.printf("Continue" ,pauseFont,.25*Width(),.50*Height(),.50*Width(),"center")
		love.graphics.printf("Main Menu",pauseFont,.25*Width(),.60*Height(),.50*Width(),"center")
		love.graphics.printf("Quit"     ,pauseFont,.25*Width(),.70*Height(),.50*Width(),"center")

		love.graphics.setColor(1,1,1,0.15) -- mostly transparent white (highlight)
		if highlighted > 0 then
			love.graphics.rectangle("fill", .40*Width(), .40*Height()+.10*Height()*highlighted, .20*Width(), pauseFont:getHeight())
		end

		love.graphics.setColor(1,1,1) -- back to default

	end
end

