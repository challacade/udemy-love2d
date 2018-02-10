coins = {}

function spawnCoin(x, y)
  local coin = {}
  coin.x = x
  coin.y = y
  coin.collected = false

  coin.grid = anim8.newGrid(41, 42, 123, 126)
  coin.animation = anim8.newAnimation(coin.grid('1-3',1, '1-3',2, '1-2',3), 0.1)

  table.insert(coins, coin)
end

function coinUpdate(dt)
  for i,c in ipairs(coins) do
    if distanceBetween(c.x, c.y, player.body:getX(), player.body:getY()) < 50 then
      c.collected = true
    end
  end

  for i=#coins,1,-1 do
    local c = coins[i]
    if c.collected == true then
      table.remove(coins, i)
    end
  end
end
