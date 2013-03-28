local ATL = require("lib/Advanced-Tiled-Loader").Loader
ATL.path = "maps/"

local map
local commander = {}
local enemy = {}

function drawSprite(sprite)
    love.graphics.draw(sprite.image, sprite.pos.x, sprite.pos.y,
        sprite.r, sprite.sx, sprite.sy,
        sprite.ox, sprite.oy)
end

function love.load()
    map = ATL.load("kingdom.tmx")
    commander.image = love.graphics.newImage("units/commander.png")
    commander.pos = {x=453, y=257}
    commander.sx = 1
    commander.sy = 1
    commander.ox = 0
    commander.oy = 0
    enemy.image = commander.image
    enemy.pos = {x=162, y=162}
    enemy.sx = -1
    enemy.sy = 1
    enemy.ox = 32
    enemy.oy = 0
end

function love.update(dt)
    if love.keyboard.isDown("w") then
        commander.pos.y = commander.pos.y - 1
    elseif love.keyboard.isDown("s") then
        commander.pos.y = commander.pos.y + 1
    end

    if love.keyboard.isDown("a") then
        commander.pos.x = commander.pos.x - 1
        commander.sx = 1
        commander.ox = 0
    elseif love.keyboard.isDown("d") then
        commander.pos.x = commander.pos.x + 1
        commander.sx = -1
        commander.ox = 32
    end
end

function love.draw()
    map:draw()
    drawSprite(commander)
    drawSprite(enemy)
    love.graphics.print(string.format(
[[Memory: %dKB
Pos: (%f, %f)
]],
    math.floor(collectgarbage("count")),
    commander.pos.x,
    commander.pos.y), 1, 1)
end



