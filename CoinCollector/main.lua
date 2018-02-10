function love.load()
  love.window.setMode(900, 700)
  love.graphics.setBackgroundColor(155, 214, 255)

  myWorld = love.physics.newWorld(0, 500, false)
  myWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)

  sprites = {}
  sprites.coin_sheet = love.graphics.newImage('sprites/coin_sheet.png')
  sprites.player_jump = love.graphics.newImage('sprites/player_jump.png')
  sprites.player_stand = love.graphics.newImage('sprites/player_stand.png')

  require('player')
  require('coin')
  require('show')
  anim8 = require('anim8-master/anim8')
  sti = require("Simple-Tiled-Implementation-master/sti")
  cameraFile = require("hump-master/camera")

  cam = cameraFile()
  gameState = 1
  myFont = love.graphics.newFont(30)
  timer = 0

  saveData = {}
  saveData.bestTime = 999

  if love.filesystem.exists("data.lua") then
    local data = love.filesystem.load("data.lua")
    data()
  end

  platforms = {}

  gameMap = sti("maps/gameMap.lua")

  for i, obj in pairs(gameMap.layers["Platforms"].objects) do
    spawnPlatform(obj.x, obj.y, obj.width, obj.height)
  end

  for i, obj in pairs(gameMap.layers["Coins"].objects) do
    spawnCoin(obj.x, obj.y)
  end
end

function love.update(dt)
  myWorld:update(dt)
  playerUpdate(dt)
  gameMap:update(dt)
  coinUpdate(dt)

  cam:lookAt(player.body:getX(), love.graphics.getHeight()/2)

  for i,c in ipairs(coins) do
    c.animation:update(dt)
  end

  if gameState == 2 then
    timer = timer + dt
  end

  if #coins == 0 and gameState == 2 then
    gameState = 1
    player.body:setPosition(198, 443)

    if #coins == 0 then
      for i, obj in pairs(gameMap.layers["Coins"].objects) do
        spawnCoin(obj.x, obj.y)
      end
    end

    if timer < saveData.bestTime then
      saveData.bestTime = math.floor(timer)
      love.filesystem.write("data.lua", table.show(saveData, "saveData"))
    end
  end
end

function love.draw()
  cam:attach()

  gameMap:drawLayer(gameMap.layers["Tile Layer 1"])

  love.graphics.draw(player.sprite, player.body:getX(), player.body:getY(), nil, player.direction, 1, sprites.player_stand:getWidth()/2, sprites.player_stand:getHeight()/2)

  for i,c in ipairs(coins) do
    c.animation:draw(sprites.coin_sheet, c.x, c.y, nil, nil, nil, 20.5, 21)
  end

  cam:detach()

  if gameState == 1 then
    love.graphics.setFont(myFont)
    love.graphics.printf("Press any key to begin!", 0, 50, love.graphics.getWidth(), "center")
    love.graphics.printf("Best Time: " .. saveData.bestTime, 0, 150, love.graphics.getWidth(), "center")
  end

  love.graphics.print("Time: " .. math.floor(timer), 10, 660)
end

function love.keypressed(key, scancode, isrepeat)
  if key == "up" and player.grounded == true then
    player.body:applyLinearImpulse(0, -2800)
  end

  if gameState == 1 then
    gameState = 2
    timer = 0
  end
end

function spawnPlatform(x, y, width, height)
  local platform = {}
  platform.body = love.physics.newBody(myWorld, x, y, "static")
  platform.shape = love.physics.newRectangleShape(width/2, height/2, width, height)
  platform.fixture = love.physics.newFixture(platform.body, platform.shape)
  platform.width = width
  platform.height = height

  table.insert(platforms, platform)
end

function beginContact(a, b, coll)
  player.grounded = true
end

function endContact(a, b, coll)
  local x, y = player.body:getLinearVelocity()
  player.grounded = false
end

function distanceBetween(x1, y1, x2, y2)
  return math.sqrt((y2 - y1)^2 + (x2 - x1)^2)
end
