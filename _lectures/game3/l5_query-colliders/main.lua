function love.load()
    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0, 800, false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('Platform')
    world:addCollisionClass('Player'--[[, {ignores = {'Platform'}}]])
    world:addCollisionClass('Danger')

    player = world:newRectangleCollider(360, 100, 80, 80, {collision_class = "Player"})
    player:setFixedRotation(true)
    player.speed = 240

    platform = world:newRectangleCollider(250, 400, 300, 100, {collision_class = "Platform"})
    platform:setType('static')

    dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"})
    dangerZone:setType('static')
end

function love.update(dt)
    world:update(dt)

    if player.body then
        local px, py = player:getPosition()
        if love.keyboard.isDown('right') then
            player:setX(px + player.speed*dt)
        end
        if love.keyboard.isDown('left') then
            player:setX(px - player.speed*dt)
        end

        if player:enter('Danger') then
            player:destroy()
        end
    end
end

function love.draw()
    world:draw()
end

function love.keypressed(key)
    if key == 'up' then
        local colliders = world:queryRectangleArea(player:getX() - 40, player:getY() + 40, 80, 2, {'Platform'})
        if #colliders > 0 then
            player:applyLinearImpulse(0, -7000)
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local colliders = world:queryCircleArea(x, y, 200, {'Platform', 'Danger'})
        for i,c in ipairs(colliders) do
            c:destroy()
        end
    end
end