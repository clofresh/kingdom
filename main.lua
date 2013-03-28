local ATL = require("lib/Advanced-Tiled-Loader").Loader
ATL.path = "maps/"

local map
local commander = {}
function love.load()
    map = ATL.load("kingdom.tmx")
    commander.image = love.graphics.newImage("units/commander.png")
    commander.pos = {x=453, y=257}
end

function love.update(dt)
    if love.keyboard.isDown("w") then
        commander.pos.y = commander.pos.y - 1
    elseif love.keyboard.isDown("s") then
        commander.pos.y = commander.pos.y + 1
    end

    if love.keyboard.isDown("a") then
        commander.pos.x = commander.pos.x - 1
    elseif love.keyboard.isDown("d") then
        commander.pos.x = commander.pos.x + 1
    end
end

function love.draw()
    map:draw()
    love.graphics.draw(commander.image, commander.pos.x, commander.pos.y)
    love.graphics.print(string.format(
[[Memory: %dKB
Pos: (%f, %f)
]],
    math.floor(collectgarbage("count")),
    commander.pos.x,
    commander.pos.y), 1, 1)
end



