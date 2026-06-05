player = {}  
enemy = {}
enemyActive = false
spawnTimer = 0
spawnDelay = 0
numRails = 6
death = {}
function love.conf(t)
    t.window.width = 720
    t.window.height = 720
    t.window.resizable = true
end
function love.load()
	    -- This is the coordinates where the player character will be rendered.
	player.x = 100   -- This sets the player at the middle of the screen based on the width of the game window. 
	player.y = love.graphics.getHeight()/numRails  -- This sets the player at the middle of the screen based on the height of the game window. 
    player.rail = 1
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

function love.keypressed(keyid, key, isrepeat)
	if gamestate == true then -- could be changed to represent more than 2 gamestates
		if key == 'w' then
			player.rail = ((player.rail + numRails - 2) % numRails) + 1 -- sub 1 and mod rails (offset due to 1 indexing)
		else if key == 's' then
			player.rail = (player.rail % numRails) + 1 -- add 1 mod rails
		end
	end
end

function love.update(dt)		
		player.y = player.rail * love.graphics.getHeight()/numRails -- move player to rail's location
		
		-- spawn delay system
		if enemyActive == false then
			spawnTimer = spawnTimer + dt

			if spawnTimer >= spawnDelay then
				spawnTimer = 0
				spawnDelay = math.random(1, 3)

				enemy.rail = math.random(1,numRails)
				enemy.x = love.graphics.getWidth()
				enemy.y = enemy.rail * love.graphics.getHeight()/numRails -- move enemy to rail's location

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
	if gamestate == false then
		love.graphics.print("Death", love.graphics.getWidth() / 2, love.graphics.getHeight()/2)
		love.graphics.draw(death.img,0, 100, 0, 1.12)
		return 
	end
	-- draw rails
	love.graphics.setColor(1, 1, 1)        -- set rail color to white
	for i = 1, numRails, 1 do
		love.graphics.rectangle("fill", 0, (i*love.graphics.getHeight()/numRails)-5, love.graphics.getWidth(), 5)
	end

	love.graphics.draw(player.img, player.x, player.y, 0, 1, 1, 0, 32)
	love.graphics.draw(enemy.img, enemy.x, enemy.y, 0, 1, 1, 0, 32)
	love.graphics.print(tostring(enemyActive), 100,100)
end

