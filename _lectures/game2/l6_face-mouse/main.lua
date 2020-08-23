function love.load()
    sprites = {}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')

    player = {}
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    player.speed = 180

    tempRotation = 0
end

function love.update(dt)
    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed*dt
    end
    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed*dt
    end
    if love.keyboard.isDown("w") then
        player.y = player.y - player.speed*dt
    end
    if love.keyboard.isDown("s") then
        player.y = player.y + player.speed*dt
    end

    tempRotation = tempRotation + 0.01
end

function love.draw()
    love.graphics.draw(sprites.background, 0, 0)

    love.graphics.draw(sprites.player, player.x, player.y, playerMouseAngle(), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)
end

function playerMouseAngle()
    return math.atan2( player.y - love.mouse.getY(), player.x - love.mouse.getX() ) + math.pi
end