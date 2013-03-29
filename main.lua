local ATL = require("lib/Advanced-Tiled-Loader").Loader
vector = require "lib/hump/vector"
ATL.path = "maps/"

local map
local commander = {}
local enemy = {}
local dialogue

function drawSprite(sprite)
    love.graphics.draw(sprite.image, sprite.pos.x, sprite.pos.y,
        sprite.r, sprite.sx, sprite.sy,
        sprite.ox, sprite.oy)
end

local leftPortrait = {x = 15, y = 340, w = 100, h = 125,
                      sx = -1, sy = 1, ox = 180, oy = 70}
leftPortrait.stencil = love.graphics.newStencil(function()
   love.graphics.rectangle("fill", leftPortrait.x, leftPortrait.y,
                           leftPortrait.w, leftPortrait.h)
end)

local rightPortrait = {x = 525, y = 340, w = 100, h = 125,
                       sx = 1, sy = 1, ox = 80, oy = 70}
rightPortrait.stencil = love.graphics.newStencil(function()
    love.graphics.rectangle("fill", rightPortrait.x, rightPortrait.y,
                            rightPortrait.w, rightPortrait.h)
end)

function drawPortrait(sprite, portrait)
    love.graphics.setStencil(portrait.stencil)
    love.graphics.rectangle("fill", 0, 0, 640, 480)
    love.graphics.draw(sprite.image, portrait.x, portrait.y,
        portrait.r, portrait.sx, portrait.sy, portrait.ox, portrait.oy)
    love.graphics.setStencil()
end

function updatePlayer(dt)
    if love.keyboard.isDown("w") then
        commander.pos.y = commander.pos.y - 1
    elseif love.keyboard.isDown("s") then
        commander.pos.y = commander.pos.y + 1
    end

    if love.keyboard.isDown("a") then
        commander.pos.x = commander.pos.x - 1
        commander.sx = 1/8
        commander.ox = 0
    elseif love.keyboard.isDown("d") then
        commander.pos.x = commander.pos.x + 1
        commander.sx = -1/8
        commander.ox = 256
    end
end

function updateEnemy(dt)
    -- Move towards the player
    enemy.pos = enemy.pos + ((commander.pos - enemy.pos):normalized() * dt * enemy.speed)
    if not enemy.spoke and (enemy.pos - commander.pos):len() < 5 then
        local script = [[Commander: Ahoy there!
Enemy: Sup!
Commander: Not much.
Enemy: Aiight.
]]
        dialogue = {
            right = commander,
            left = enemy,
            script = script:gmatch('(.-)\n()'),
            done = false,
        }
        dialogue.currentLine = dialogue.script()
        enemy.spoke = true
    end
end

function love.load()
    map = ATL.load("kingdom.tmx")
    commander.image = love.graphics.newImage("units/commander.png")
    commander.pos = vector(453, 257)
    commander.sx = 1/8
    commander.sy = 1/8
    commander.ox = 0
    commander.oy = 0
    enemy.image = commander.image
    enemy.pos = vector(162, 162)
    enemy.sx = -1/8
    enemy.sy = 1/8
    enemy.ox = 256
    enemy.oy = 0
    enemy.speed = 20
    enemy.spoke = false
end

function love.update(dt)
    if not dialogue then
        updatePlayer(dt)
        updateEnemy(dt)
    end
end

function love.keyreleased(key)
    if dialogue and key == "return" then
        dialogue.currentLine = dialogue.script()
        if not dialogue.currentLine then
            dialogue.done = true
        end
    end
end

function love.draw()
    map:draw()
    drawSprite(commander)
    drawSprite(enemy)
    if dialogue then
        drawPortrait(dialogue.right, rightPortrait)
        drawPortrait(dialogue.left, leftPortrait)
        if dialogue.done then
            dialogue = nil
        elseif dialogue.currentLine then
            love.graphics.print(dialogue.currentLine, 150, 430)
        end
    end

    love.graphics.print(string.format(
[[Memory: %dKB
Pos: (%f, %f)
]],
    math.floor(collectgarbage("count")),
    commander.pos.x,
    commander.pos.y), 1, 1)
end



