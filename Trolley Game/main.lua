player = {}  
enemies = {}
collectibles = {}
score = 0
spawnTimer = 0
spawnDelay = 0
numRails = 6
sprites = {}
gamestates = {["alive"] = 1, ["dead"] = 2, ["menu"] = 3, ["paused"] = 4, ["loading"] = 5}
gamestate = gamestates.menu -- you should start on the menu
enemyTypes = {}
rails = {}
railSpeed = 300
bullets = {}
enemyBullets = {}
rockets = {}
lasers = {}
bulletSpeed = 500
rocketSpeed = 750
laserSpeed = 700
rocketWarningDuration = 1.4
laserWarningDuration = 1.0
laserInactiveDuration = 1.4
barrierEnemyCooldown = 0
barrierEnemyDelay = 0.5
threatSpawnTimer = 0
threatSpawnDelay = 0
padding = 40
deathReason = "Error"
pauseFont = love.graphics.newFont(32) -- size 32 default font
scoreFont = love.graphics.newFont(26)
highlighted = 0 -- which option in a menu is highlighted, 0 means none, 1 is first

function Width()
	return love.graphics.getWidth()
end

function Height()
	return love.graphics.getHeight()
end

function generateRail(i,j)
	local tile = {
		x = (j > 1) and rails[i][j-1].x + rails[i][j-1].img:getWidth() or 0,
		y=padding + (i) * getRailHeight() + math.random(-2,2)
	}

 	-- 3% chance of becoming a barrier
    if math.random() < 0.03 and timeSinceStart > 1 and barrierEnemyCooldown <= 0 then
        tile.img = barrierImg
        tile.type = "barrier"
        barrierEnemyCooldown = barrierEnemyDelay
    else
        tile.img = railImg
        tile.type = "rail"
    end

    return tile
end

function resetBgTiles()
	backgroundTiles = {}
	backgroundTiles.a = { x = 0, y = 0 }
	if sprites and sprites.background then
		backgroundTiles.b = { x = sprites.background:getWidth(), y = 0 }
	else
		backgroundTiles.b = { x = Width(), y = 0 }
	end
end

function love.load()

	anim8 = require 'libraries/anim8'
	
	
	-- reset everything
	enemies = {}
	collectibles = {}
	spawnTimer = 0
	spawnDelay = 0
	rails = {}
	resetBgTiles()
	bullets = {}
	score = 0
	timeSinceStart = 0
	animationTimer = 0
	deathReason = "Error"

    love.window.setTitle("Trolley Troubles")

	    -- This is the coordinates where the player character will be rendered.
	player.x = 100   -- This sets the player at the middle of the screen based on the width of the game window. 
	player.y = love.graphics.getHeight()/numRails  -- This sets the player at the middle of the screen based on the height of the game window and number of rails. 
	player.rail = 1
	player.animTimer = 50
	player.bounceDirection = -4
	player.img = love.graphics.newImage('assets/sprites/trolley.png')
	player.width = player.img:getWidth()
	player.height = player.img:getHeight()
	player.ground = player.y     -- This makes the character land on the platform.
	player.speed = 200
	player.facing = 1 -- 1 = right, -1 = left
	player.fireRate = 0.25 -- can shoot shoot 4 bullets per second
	player.fireCooldown = 0
	spawnTimer = 0
	spawnDelay = math.random(1, 3)
	rockets = {}
	lasers = {}
	barrierEnemyCooldown = 0
	threatSpawnTimer = 0
	threatSpawnDelay = math.random(3, 6)
	gamestate = gamestates.menu -- change later when main menu added
	sprites.background = love.graphics.newImage('assets/sprites/background_texture.png')
	sprites.death = love.graphics.newImage('assets/sprites/gameover.png')
	sprites.start = love.graphics.newImage('assets/sprites/start.png')
	sprites.paused = love.graphics.newImage('assets/sprites/paused.png')
	sprites.warning = love.graphics.newImage('assets/sprites/warning_placeholder.png')
	sprites.warningLaser = love.graphics.newImage('assets/sprites/warning_placeholder_laser.png')
	sprites.rocket = love.graphics.newImage('assets/sprites/rocket.png')
	sprites.bullet = love.graphics.newImage('assets/sprites/bullet.png')
	sprites.enemy_bullet = love.graphics.newImage('assets/sprites/enemy_bullet.png')
	sprites.menu = love.graphics.newImage('assets/sprites/title_screen.png')
	sprites.resume = love.graphics.newImage('assets/sprites/resume.png')
	sprites.resume_sel = love.graphics.newImage('assets/sprites/resume_selected.png')
	sprites.retry = love.graphics.newImage('assets/sprites/retry.png')
	sprites.retry_sel = love.graphics.newImage('assets/sprites/retry_selected.png')
	sprites.quit = love.graphics.newImage('assets/sprites/quit.png')
	sprites.quit_sel = love.graphics.newImage('assets/sprites/quit_selected.png')
	sprites.mainmenu = love.graphics.newImage('assets/sprites/menu.png')
	sprites.mainmenu_sel = love.graphics.newImage('assets/sprites/menu_selected.png')
	sprites.laser_active = love.graphics.newImage('assets/sprites/laser_active.png')
	sprites.laser_inactive = love.graphics.newImage('assets/sprites/laser_inactive.png')
	sprites.laser_warning = love.graphics.newImage('assets/sprites/warning_1.png')
	sprites.rocket_warning = love.graphics.newImage('assets/sprites/warning_2.png')
	sprites.score_area = love.graphics.newImage('assets/sprites/score_area.png')


	enemyTypes = {

    	dasher = {
        	image = love.graphics.newImage("assets/sprites/handcar_sheet.png"),
			dash = love.graphics.newImage("assets/sprites/handcar_dash.png"),
        	speed = 50
    	},

    	shooter = {
        	image = love.graphics.newImage("assets/sprites/shooter_sheet.png"),
        	speed = 25
    	}
	}
	collectibleTypes = {
    	people = {
      		image = love.graphics.newImage('assets/sprites/people.png'),
      		speed = 300,
      		collectibleScore = 300
    	}
  	}
	--Handcar animation setup
	enemyTypes.dasher.grid = anim8.newGrid(168, 156, enemyTypes.dasher.image:getWidth(), enemyTypes.dasher.image:getHeight())
	enemyTypes.dasher.animations = {}
	enemyTypes.dasher.animations.move = anim8.newAnimation(enemyTypes.dasher.grid('1-2', 1), 0.8)
	--Shooter animation setup
	enemyTypes.shooter.grid = anim8.newGrid(195, 112, enemyTypes.shooter.image:getWidth(), enemyTypes.shooter.image:getHeight())
	enemyTypes.shooter.animations = {}
	enemyTypes.shooter.animations.move = anim8.newAnimation(enemyTypes.shooter.grid('1-3', 1), 0.3)


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
    		local bullet = {
      			x = player.x + player.img:getWidth(),
      			y = player.y + player.img:getHeight() / 2 - sprites.bullet:getHeight() / 2,
      			width = sprites.bullet:getWidth(),
      			height = sprites.bullet:getHeight(),
      			img = sprites.bullet,
      			vx = bulletSpeed,
      			vy = 0,
      			owner = "player"
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
		elseif key == 'space' or key == 'enter' then
			if highlighted == 1 then
				gamestate = gamestates.alive
			elseif highlighted == 2 then
				love.load()
				gamestate = gamestates.menu
				
				-- maybe reset game here? i dont know
			elseif highlighted == 3 then
				-- save data?
				love.event.quit(0) -- quit gracefully
			end
		end
		elseif gamestate == gamestates.dead then
		if key == 'w' then
			highlighted = indexMod(highlighted, -1, 3)
		elseif key == 's' then
			highlighted = indexMod(highlighted, 1, 3)
		elseif key == 'space' or key == 'enter' then
			if highlighted == 1 then
				love.load()
				gamestate = gamestates.loading
			elseif highlighted == 2 then
				love.load()
				gamestate = gamestates.menu
			elseif highlighted == 3 then
				love.event.quit(0)
			end
		end
	elseif gamestate == gamestates.menu then
		if key == 'space' or key == 'enter' then
			gamestate = gamestates.loading
		end
	end
end
function love.update(dt)
	if gamestate == gamestates.menu then
		if love.mouse.isDown(1) then
			x, y = love.mouse.getPosition()
			if (x > Width()/2 - sprites.start:getWidth()/2 and x < Width()/2 + sprites.start:getWidth()/2) and (y > Height()/2 - sprites.start:getHeight()/2 and y < Height()/2 + sprites.start:getHeight()/2) then
				gamestate = gamestates.loading
			end
		end
	elseif gamestate == gamestates.loading then
		love.timer.sleep(0.5)
		gamestate = gamestates.alive
	elseif gamestate == gamestates.paused then
		local x, y = love.mouse.getPosition()
		for i=1,3 do
			if (x > Width()/2 - sprites.resume:getWidth()/2 and x < Width()/2 + sprites.resume:getWidth()/2 and y >.40*Height()+.10*Height()*i and y < .40*Height()+.10*Height()*i+sprites.resume:getHeight()) then
				highlighted = i
				if love.mouse.isDown(1) then
					if highlighted == 1 then
						gamestate = gamestates.alive
					elseif highlighted == 2 then
						love.load()
						gamestate = gamestates.menu
					elseif highlighted == 3 then
						love.event.quit(0)
					end
				end
				break
			end
		end
	elseif gamestate == gamestates.dead then
		local x, y = love.mouse.getPosition()
		for i=1,3 do
			if (x > Width()/2 - sprites.resume:getWidth()/2 and x < Width()/2 + sprites.resume:getWidth()/2 and y >.50*Height()+.10*Height()*i and y < .50*Height()+.10*Height()*i+sprites.resume:getHeight()) then
				highlighted = i
				if love.mouse.isDown(1) then
					if highlighted == 1 then
						love.load()
						gamestate = gamestates.loading
					elseif highlighted == 2 then
						love.load()
						gamestate = gamestates.menu
					elseif highlighted == 3 then
						love.event.quit(0)
					end
				end
				break
			end
		end
	elseif gamestate == gamestates.alive then

		timeSinceStart = timeSinceStart + dt

		-- animate background tiles and wrap when a tile moves fully off-screen
		local bgScale = 1.5
		local bgW = sprites.background and (sprites.background:getWidth() * bgScale) or Width()
		backgroundTiles.a.x = backgroundTiles.a.x - (railSpeed * dt)
		backgroundTiles.b.x = backgroundTiles.b.x - (railSpeed * dt)
		-- if a tile has moved fully off the left edge, move it to the right of the other tile
		if backgroundTiles.a.x + bgW <= 0 then
			backgroundTiles.a.x = backgroundTiles.b.x + bgW
		end
		if backgroundTiles.b.x + bgW <= 0 then
			backgroundTiles.b.x = backgroundTiles.a.x + bgW
		end

		--checks if the game is over every tick based on whether you died or not
		score = score + dt
		player.fireCooldown = player.fireCooldown - dt
		if player.fireCooldown < 0 then
			player.fireCooldown = 0
		end		
		local railHeight = getRailHeight()
		player.y = padding + (player.rail) * railHeight - player.img:getHeight() -- move player to rail's location
		for i = #bullets, 1, - 1 do
      		local bullet = bullets[i]
			if bullet.owner == "player" then
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
			elseif bullet.owner == "enemy" then
				local originalY = bullet.y
				bullet.y = bullet.y - 80
				if checkCollision(bullet, player) then
					table.remove(bullets, i)
					gamestate = gamestates.dead
					deathReason = "Shot by an enemy"
				end
				bullet.y = originalY
			end
    	end
		for i = #bullets, 1, - 1 do
    		local bullet = bullets[i]

    	if bullet.vx or bullet.vy then
    		bullet.x = bullet.x + (bullet.vx or 0) * dt
    		bullet.y = bullet.y + (bullet.vy or 0) * dt
    	else
    		bullet.x = bullet.x + bullet.speed * bullet.facing * dt
    	end

    	-- Remove off-screen bullets
    	if bullet.x < 0 or bullet.x > Width() or bullet.y < 0 or bullet.y > Height() then
      			table.remove(bullets, i)
    		end
  		end
		-- spawn delay and spawn system
		spawnTimer = spawnTimer + dt

		if spawnTimer >= spawnDelay then
    		spawnTimer = 0
    		spawnDelay = math.random(1, 3)
    		if barrierEnemyCooldown <= 0 then
    			spawnEnemy()
    			barrierEnemyCooldown = barrierEnemyDelay
    		end
			spawnCollectible()
		end

		-- shared barrier/enemy cooldown
		if barrierEnemyCooldown > 0 then
			barrierEnemyCooldown = barrierEnemyCooldown - dt
			if barrierEnemyCooldown < 0 then
				barrierEnemyCooldown = 0
			end
		end

		-- shared rocket/laser threat spawn timer
		threatSpawnTimer = threatSpawnTimer + dt
		if threatSpawnTimer >= threatSpawnDelay then
			threatSpawnTimer = 0
			threatSpawnDelay = math.random(2, 4)
			if math.random() < 0.5 then
				spawnRocketWarning()
			else
				spawnLaserWarning()
			end
		end

		-- movement
		for i, enemy in ipairs(enemies) do

    		if enemy.type == "dasher" then
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

    			enemy.shootTimer = enemy.shootTimer - dt

    			if enemy.shootTimer <= 0 then
        			spawnEnemyBullet(enemy)

        			-- fire every 1–2 seconds
        			enemy.shootTimer = 1 + math.random()
    			end
			end
		end
			
		-- reset
		for i = #enemies, 1, -1 do
    		if enemies[i].x < -50 then
        		table.remove(enemies, i)
    		end
		end

		enemyTypes.dasher.animations.move:update(dt)
		enemyTypes.shooter.animations.move:update(dt)

		-- rocket warning countdown and active rocket movement
		for i = #rockets, 1, -1 do
			local rocket = rockets[i]
			if rocket.state == "warning" then
				rocket.timer = rocket.timer - dt
				rocket.flashTimer = rocket.flashTimer + dt
				if rocket.timer <= 0 then
					rocket.state = "active"
					-- set active (scaled) dimensions and align Y to the rail
					rocket.width = rocket.activeWidth
					rocket.height = rocket.activeHeight
					rocket.y = padding + (rocket.rail) * getRailHeight() - rocket.height
				end
			else
				rocket.x = rocket.x - rocket.speed * dt
			end

			if rocket.x + rocket.width < 0 then
				table.remove(rockets, i)
			elseif rocket.state == "active" and checkCollision(player, rocket) then
				gamestate = gamestates.dead
				deathReason = "Hit by a rocket"
			end
		end

		-- laser warning, inactive warning, and active laser timing
		for i = #lasers, 1, -1 do
			local laser = lasers[i]
			if laser.state == "warning" then
				laser.timer = laser.timer - dt
				laser.flashTimer = laser.flashTimer + dt
				if laser.timer <= 0 then
					laser.state = "inactive"
					laser.timer = laser.inactiveDuration
				end
			elseif laser.state == "inactive" then
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
				deathReason = "Incinerated by a laser"
			end
		end
		--collision check
		for i, enemy in ipairs(enemies) do
        	if checkCollision(player, enemy) then
            	gamestate = gamestates.dead
				deathReason = "Ran into an enemy"
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
						deathReason = "Hit a barrier"
            		end
        		end
    		end
		end
		-- rail tile movement
		for i = 1, #rails do
			for j = 1, #rails[i] do
				local rail = rails[i][j]
				rail.x = rail.x - railSpeed * dt
			end
			if -rails[i][1].x >= rails[i][1].img:getWidth() then
				table.remove(rails[i], 1)
				rails[i][#rails[i]+1] = generateRail(i,#rails[i]+1)
			end
		end
		--COLLECTIBLES
		-- movement
		for i, collectible in ipairs(collectibles) do

			if collectible.type == "people" then
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


		if player.animTimer > 0 then -- This controls the trolley's "bouncing" animation on the tracks
			player.animTimer = player.animTimer - 1
		else
			player.animTimer = 50
			player.x = player.x + player.bounceDirection
			player.bounceDirection = -player.bounceDirection
		end
		-----------------
	end
end

function spawnCollectible()
  local types = {"people"}
  local collectibleType = types[math.random(#types)]
  local rail = math.random(1, numRails)
  local data = collectibleTypes[collectibleType]

  local railHeight = getRailHeight()
  local collectible = {
    type = collectibleType,
    x = Width(),
    speed = data.speed,
    y = padding + (rail) * railHeight - data.image:getHeight(),
    img = data.image,
    collectibleScore = data.collectibleScore
  }

  table.insert(collectibles, collectible)
end

function spawnEnemyBullet(enemy)
    local bullet = {
    x = enemy.x,
    y = enemy.y + enemy.img:getHeight() / 2 - sprites.enemy_bullet:getHeight() / 2,
    width = sprites.enemy_bullet:getWidth(),
    height = sprites.enemy_bullet:getHeight(),
    img = sprites.enemy_bullet,
    vx = -bulletSpeed,
    vy = 0,
    owner = "enemy"
}
    table.insert(bullets, bullet)
end
function spawnEnemy()

    local types = { "dasher", "shooter"}
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
		y = padding + (rail) * railHeight - data.image:getHeight(),
        img = data.image,
		dash = true,
		bullet = true,
		dashTimer = 0,
    	dashCooldown = math.random(2,5),
		hp = 50
    }

    if enemy.type == "shooter" then
        enemy.shootTimer = 1.5 + math.random() * 1.5
    end
    table.insert(enemies, enemy)
end

function spawnRocketWarning()
    local rail = math.random(1, numRails)
    local railHeight = getRailHeight()
    local warningWidth = sprites.warning:getWidth()
    local warningHeight = sprites.warning:getHeight()
    local rocket = {
        x = Width() - warningWidth - 10,
        y = padding + (rail) * railHeight - warningHeight,
        width = warningWidth,
        height = warningHeight,
        speed = rocketSpeed,
        state = "warning",
        timer = rocketWarningDuration,
        warningImg = sprites.rocket_warning,
        img = sprites.rocket,
        rail = rail,
		-- active (fired) rocket scale and cached dimensions
		activeScale = 0.17,
		activeWidth = sprites.rocket:getWidth() * 0.17,
		activeHeight = sprites.rocket:getHeight() * 0.17 + 30,
        flashTimer = 0
    }
    table.insert(rockets, rocket)
end

function spawnLaserWarning()
    local rail = math.random(1, numRails)
    local railHeight = getRailHeight()
    local warningWidth = sprites.warningLaser:getWidth()
    local warningHeight = sprites.warningLaser:getHeight()
    local inactiveScale = 1.5
    local inactiveWidth = sprites.laser_inactive:getWidth() * inactiveScale
    local inactiveHeight = sprites.laser_inactive:getHeight() * inactiveScale
    local laserHeight = railHeight - 8
    local laser = {
        warningX = Width() - warningWidth - 10,
        warningY = padding + (rail) * railHeight - warningHeight,
        inactiveX = Width() - inactiveWidth - 10,
        inactiveY = padding + (rail) * railHeight - inactiveHeight,
        x = 0,
        y = padding + (rail) * railHeight - laserHeight,
        width = Width(),
        height = laserHeight,
        state = "warning",
        timer = laserWarningDuration,
        inactiveDuration = laserInactiveDuration,
        activeDuration = 0.2,
        activeTimer = 0,
        img = sprites.laser_warning,
        inactiveImg = sprites.laser_inactive,
        inactiveScale = inactiveScale,
        activeImg = sprites.laser_active,
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
	local aw = a.width or (a.img and a.img:getWidth()) or 0
	local ah = 80
	local bw = b.width or (b.img and b.img:getWidth()) or 0
	local bh = 80
	return a.x < b.x + bw and
		   a.x + aw > b.x and
		   a.y < b.y + bh and
		   a.y + ah > b.y
end

function love.draw()

	if gamestate == gamestates.menu then
		love.graphics.draw(sprites.menu, 0, 0)
		love.graphics.print(Width(), 0, 0)
		love.graphics.print(Height(), 0, 20)
		love.graphics.draw(sprites.start, Width()/2 - sprites.start:getWidth()/2, Height()/2 - sprites.start:getHeight()/2)
	end
	if gamestate == gamestates.loading then
		love.graphics.print("Loading...", Width()/2, Height()/2, 0)
	end
	-- love.graphics.print(gamestate, love.graphics.getWidth() / 2, love.graphics.getHeight()/2)
	if gamestate == gamestates.dead then
		love.graphics.draw(sprites.death, Width()/2 - sprites.death:getWidth()/2, Height()/2 - sprites.death:getHeight(), 0, 1, 1, 1)

		-- love.graphics.setColor(1,1,1) -- regular white (for now)

		love.graphics.draw(sprites.retry,Width()/2 - sprites.retry:getWidth()/2,.60*Height())
		love.graphics.draw(sprites.mainmenu,Width()/2 - sprites.mainmenu:getWidth()/2,.70*Height())
		love.graphics.draw(sprites.quit,Width()/2 - sprites.quit:getWidth()/2,.80*Height())
		
		love.graphics.setColor(1,0,0) -- red text
		love.graphics.printf(deathReason,pauseFont,.25*Width(),.525*Height(),.50*Width(),"center")
		love.graphics.setColor(1,1,1) -- default/white text

		-- love.graphics.setColor(1,1,1,0.15) -- mostly transparent white (highlight)
		if highlighted > 0 then
			if highlighted == 1 then
				love.graphics.draw(sprites.retry_sel,Width()/2 - sprites.retry_sel:getWidth()/2,.60*Height())
			elseif highlighted == 2 then
				love.graphics.draw(sprites.mainmenu_sel,Width()/2 - sprites.mainmenu_sel:getWidth()/2,.70*Height())
			elseif highlighted == 3 then
				love.graphics.draw(sprites.quit_sel,Width()/2 - sprites.quit_sel:getWidth()/2,.80*Height())
			end
		end

		-- love.graphics.setColor(1,1,1) -- back to default
	end
	if gamestate == gamestates.alive or gamestate == gamestates.paused then
		love.graphics.draw(sprites.background, backgroundTiles.a.x, backgroundTiles.a.y, 0, 1.5, 1.5)
		love.graphics.draw(sprites.background, backgroundTiles.b.x, backgroundTiles.b.y, 0, 1.5, 1.5)
		love.graphics.setColor(1, 1, 1)        -- set rail color to white
	
		-- love.graphics.setColor(1,0,0) -- hitbox height debugging
		-- love.graphics.rectangle('fill', 800, 400, 80, 80)
		-- love.graphics.setColor(0,0,0)

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
    	

			-- The platform will now be drawn as a white rectangle while taking in the variables we declared above.
		love.graphics.draw(player.img, player.x, player.y)

		
		for i, enemy in ipairs(enemies) do
			if enemy.type == "dasher" then
				if enemy.dashTimer <= 0 then
					enemyTypes.dasher.animations.move:draw(enemyTypes.dasher.image, enemy.x, enemy.y)
				else
					love.graphics.draw(enemyTypes.dasher.dash, enemy.x, enemy.y)
				end
			elseif enemy.type == "shooter" then
				enemyTypes.shooter.animations.move:draw(enemyTypes.shooter.image, enemy.x, enemy.y)
			else
				love.graphics.draw(enemy.img, enemy.x, enemy.y)
			end
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
			local flashInterval = 0.15
			if laser.state == "warning" then
				if math.floor(laser.flashTimer / flashInterval) % 2 == 0 then
					love.graphics.setColor(1, 1, 1)
					love.graphics.draw(laser.img, laser.warningX, laser.warningY)
				end
			elseif laser.state == "inactive" then
				local beamX = laser.inactiveX + laser.inactiveImg:getWidth() * laser.inactiveScale * 0.5
				local beamY = laser.inactiveY + laser.inactiveImg:getHeight() * laser.inactiveScale * 0.5 - 3
				if math.floor(laser.flashTimer / flashInterval) % 2 == 0 then
					love.graphics.setColor(1, 0, 0)
					love.graphics.rectangle("fill", 0, beamY, beamX, 6)
				end
				love.graphics.setColor(1, 1, 1)
				love.graphics.draw(laser.inactiveImg, laser.inactiveX, laser.inactiveY, 0, laser.inactiveScale, laser.inactiveScale)
			else
				love.graphics.setColor(1, 1, 1)
				local scaleX = Width() / laser.activeImg:getWidth()
				local scaleY = laser.height / laser.activeImg:getHeight()
				love.graphics.draw(laser.activeImg, 0, laser.y, 0, scaleX, scaleY)
			end
		end
		love.graphics.setColor(1, 1, 1)		
		for i, collectible in ipairs(collectibles) do
      		love.graphics.draw(collectible.img, collectible.x, collectible.y+40, 0, 0.75,0.75)
    	end
		-- Draw bullets
		for i, bullet in ipairs(bullets) do
			local sx = bullet.owner == "enemy" and -1 or 1
			local ox = bullet.owner == "enemy" and bullet.img:getWidth() or 0
			love.graphics.draw(bullet.img, bullet.x, bullet.y, 0, sx, 1, ox, 0)
		end

		-- Print at 80% away across the screen & top right
    	love.graphics.print("Score: " .. math.floor(score), scoreFont, .80*Width(), scoreFont:getHeight())
	end
	if gamestate == gamestates.paused then
		love.graphics.setColor(0,0,0,0.85) -- high alpha black rectangle over the whole screen
		love.graphics.rectangle("fill",0,0,Width(),Height())

		love.graphics.setColor(1,1,1) -- regular white (for now)

		love.graphics.draw(sprites.paused, Width()/2 - sprites.paused:getWidth()/2, .25*Height() - sprites.paused:getHeight()/2)
		love.graphics.draw(sprites.resume,Width()/2 - sprites.resume:getWidth()/2,.50*Height())
		love.graphics.draw(sprites.mainmenu,Width()/2 - sprites.mainmenu:getWidth()/2,.60*Height())
		love.graphics.draw(sprites.quit,Width()/2 - sprites.quit:getWidth()/2,.70*Height())

		-- love.graphics.setColor(1,1,1,0.15) -- mostly transparent white (highlight)
		if highlighted > 0 then
			if highlighted == 1 then
				love.graphics.draw(sprites.resume_sel,Width()/2 - sprites.resume:getWidth()/2,.50*Height())
			elseif highlighted == 2 then
				love.graphics.draw(sprites.mainmenu_sel,Width()/2 - sprites.mainmenu:getWidth()/2,.60*Height())
			elseif highlighted == 3 then
				love.graphics.draw(sprites.quit_sel,Width()/2 - sprites.quit:getWidth()/2,.70*Height())
			end
		end

		-- love.graphics.setColor(1,1,1) -- back to default

	end
end


