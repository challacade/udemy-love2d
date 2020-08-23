function love.load()

end

function love.update(dt)

end

function love.draw()
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 200, 250, 200, 100)

    love.graphics.setColor(255/255, 102/255, 153/255)
    love.graphics.circle("fill", 300, 200, 100)
end