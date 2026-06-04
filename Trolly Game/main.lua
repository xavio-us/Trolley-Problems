player = {}  
enemy = {}
enemyActive = false
spawnTimer = 0
spawnDelay = 0
death = {}
function love.conf(t)
    t.window.width = 720
    t.window.height = 720
    t.window.resizable = true
end
function love.load()
	    -- This is the coordinates where the player character will be rendered.
	player.x = 100   -- This sets the player at the middle of the screen based on the width of the game window. 
	player.y = 240 or 480  -- This sets the player at the middle of the screen based on the height of the game window. 
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
			if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
				player.x = player.x + (player.speed * dt)
			end
		elseif love.keyboard.isDown('a') then
			-- This makes sure that the character doesn't go pass the game window's left edge.
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
	end	
end
function checkCollision(a, b)
    return a.x < b.x + b.img:getWidth() and
           a.x + a.img:getWidth() > b.x and
           a.y < b.y + b.img:getHeight() and
           a.y + a.img:getHeight() > b.y
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
	if gamestate == false then
		love.graphics.print("Death", love .graphics.getWidth() / 2, love.graphics.getHeight()/2)
		love.graphics.draw(death.img,0, 100, 0, 1.12)

	end
end

