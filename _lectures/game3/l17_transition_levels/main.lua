function love.load()
    love.window.setMode(1000, 768)

    anim8 = require 'libraries/anim8/anim8'
    sti = require 'libraries/Simple-Tiled-Implementation/sti'
    cameraFile = require 'libraries/hump/camera'

    cam = cameraFile()

    sprites = {}
    sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')
    sprites.enemySheet = love.graphics.newImage('sprites/enemySheet.png')

    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())
    local enemyGrid = anim8.newGrid(100, 79, sprites.enemySheet:getWidth(), sprites.enemySheet:getHeight())

    animations = {}
    animations.idle = anim8.newAnimation(grid('1-15',1), 0.05)
    animations.jump = anim8.newAnimation(grid('1-7',2), 0.05)
    animations.run = anim8.newAnimation(grid('1-15',3), 0.05)
    animations.enemy = anim8.newAnimation(enemyGrid('1-2',1), 0.03)

    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0, 800, false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('Platform')
    world:addCollisionClass('Player'--[[, {ignores = {'Platform'}}]])
    world:addCollisionClass('Danger')

    require('player')
    require('enemy')

    --dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"})
    --dangerZone:setType('static')

    platforms = {}

    flagX = 0
    flagY = 0

    currentLevel = "level1"

    loadMap(currentLevel)
end

function love.update(dt)
    world:update(dt)
    gameMap:update(dt)
    playerUpdate(dt)
    updateEnemies(dt)

    local px, py = player:getPosition()
    cam:lookAt(px, love.graphics.getHeight()/2)

    local colliders = world:queryCircleArea(flagX, flagY, 10, {'Player'})
    if #colliders > 0 then
        if currentLevel == "level1" then
            loadMap("level2")
        elseif currentLevel == "level2" then
            loadMap("level1")
        end
    end
end

function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        world:draw()
        drawPlayer()
        drawEnemies()
    cam:detach()
end

function love.keypressed(key)
    if key == 'up' then
        if player.grounded then
            player:applyLinearImpulse(0, -4000)
        end
    end
    if key == 'r' then
        loadMap("level2")
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

function spawnPlatform(x, y, width, height)
    local platform = world:newRectangleCollider(x, y, width, height, {collision_class = "Platform"})
    platform:setType('static')
    table.insert(platforms, platform)
end

function destroyAll()
    local i = #platforms
    while i > -1 do
        if platforms[i] ~= nil then
            platforms[i]:destroy()
        end
        table.remove(platforms, i)
        i = i -1
    end

    local i = #enemies
    while i > -1 do
        if enemies[i] ~= nil then
            enemies[i]:destroy()
        end
        table.remove(enemies, i)
        i = i -1
    end
end

function loadMap(mapName)
    currentLevel = mapName
    destroyAll()
    player:setPosition(300, 100)
    gameMap = sti("maps/" .. mapName .. ".lua")
    for i, obj in pairs(gameMap.layers["Platforms"].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end
    for i, obj in pairs(gameMap.layers["Enemies"].objects) do
        spawnEnemy(obj.x, obj.y)
    end
    for i, obj in pairs(gameMap.layers["Flag"].objects) do
        flagX = obj.x
        flagY = obj.y
    end
end