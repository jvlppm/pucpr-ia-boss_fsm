boomboom = require "boomboom"

screen = {
    width = 800,
    height = 600
}

boss = boomboom.create()
boss:present()

function love.update(dt)
   boss:update(dt)
end

function love.draw(dt)
    love.graphics.print(boss.info.status, 100, 100)
    boss:draw(dt)
end

function love.mousepressed(x, y, button)
    if button == "l" then
        if boss:overlapping(x, y) then
            boss:hit()
        end
    end
end
