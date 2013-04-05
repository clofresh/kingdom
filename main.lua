local ATL = require("lib/Advanced-Tiled-Loader").Loader
Class = require "lib/hump/class"
vector = require "lib/hump/vector"
ATL.path = "maps/"

local map
local commander = {}
local enemy = {}
local eventStack
local positions = {}

EventStack = Class{function(self, events)
    self.events = {}
    for i, event in pairs(events) do
        self:push(event)
    end
end}

function EventStack:pop()
    local event = table.remove(self.events)
    if event then
        print("Untriggering " .. event.name)
        event:unload()
    end
    return event
end

function EventStack:push(event)
    print("Triggering " .. event.name)
    event:load()
    table.insert(self.events, event)
end

function EventStack:peek(val)
    return self.events[#self.events]
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

local overworld = {
    name = 'overworld',
    load = function(self)
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
        enemy.onCollision = {
            name = 'greetings',
            load = function(self)
                local script = [[Commander: Ahoy there!
Enemy: Sup!
Commander: Not much.
Enemy: Aiight.
]]
                self.script = script:gmatch('(.-)\n()')
                self.currentLine = self.script()
                self.right = commander
                self.left = enemy

                love.keyreleased = function(key)
                    if key == "return" then
                        self.currentLine = self.script()
                        if not self.currentLine then
                            eventStack:pop()
                        end
                    end
                end

            end,
            unload = function(self)
                love.keyreleased = nil
            end,
            update = function(self, dt)
            end,
            draw = function(self)
                drawPortrait(self.right, rightPortrait)
                drawPortrait(self.left, leftPortrait)
                if self.currentLine then
                    love.graphics.print(self.currentLine, 150, 430)
                end
            end
        }

    end,
    unload = function(self)
    end,
    update = function(self, dt)
        updatePlayer(dt)
        updateEnemy(dt)
        for x, ys in pairs(positions) do
            for y, sprites in pairs(ys) do
                if #sprites > 1 then
                    for i, sprite in pairs(sprites) do
                        if sprite.onCollision then
                            eventStack:push(sprite.onCollision)
                            sprite.onCollision = nil
                        end
                    end
                end
            end
        end
        positions = {}
    end,
    draw = function(self)
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
}

function drawSprite(sprite)
    love.graphics.draw(sprite.image, sprite.pos.x, sprite.pos.y,
        sprite.r, sprite.sx, sprite.sy,
        sprite.ox, sprite.oy)
end

function drawPortrait(sprite, portrait)
    love.graphics.setStencil(portrait.stencil)
    love.graphics.rectangle("fill", 0, 0, 640, 480)
    love.graphics.draw(sprite.image, portrait.x, portrait.y,
        portrait.r, portrait.sx, portrait.sy, portrait.ox, portrait.oy)
    love.graphics.setStencil()
end

function registerPosition(sprite)
    local x = math.floor(sprite.pos.x / 32)
    local y = math.floor(sprite.pos.y / 32)
    if not positions[x] then
        positions[x] = {[y] = {sprite}}
    elseif not positions[x][y] then
        positions[x][y] = {sprite}
    else
        table.insert(positions[x][y], sprite)
    end
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
    registerPosition(commander)
end

function updateEnemy(dt)
    -- Move towards the player
    enemy.pos = enemy.pos + ((commander.pos - enemy.pos):normalized() * dt * enemy.speed)
    registerPosition(enemy)
end

function love.load()
    eventStack = EventStack({overworld})
end

function love.update(dt)
    local currentEvent = eventStack:peek()
    if currentEvent then
        currentEvent:update(dt)
    end
end

function love.draw()
    for i, event in pairs(eventStack.events) do
        event:draw()
    end
end



