local ATL = require("lib/Advanced-Tiled-Loader").Loader
Class = require "lib/hump/class"
vector = require "lib/hump/vector"
ATL.path = "maps/"

EventStack = require("src/event").EventStack
dialogue = require("src/dialogue")
sprite = require("src/sprite")

local map
local commander = {}
local enemy = {}
local eventStack

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
                self.script = dialogue.lineIterator(script)
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
                dialogue.draw(self.left, self.right, self.currentLine)
            end
        }

    end,
    unload = function(self)
    end,
    update = function(self, dt)
        updatePlayer(dt)
        updateEnemy(dt)
        sprite.checkCollisions(dt, function(sprites)
            for i, sprite in pairs(sprites) do
                if sprite.onCollision then
                    eventStack:push(sprite.onCollision)
                    sprite.onCollision = nil
                end
            end
        end)
    end,
    draw = function(self)
        map:draw()
        sprite.draw(commander)
        sprite.draw(enemy)

        love.graphics.print(string.format(
    [[Memory: %dKB
Pos: (%f, %f)
]],
        math.floor(collectgarbage("count")),
        commander.pos.x,
        commander.pos.y), 1, 1)
    end
}

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
    sprite.registerPosition(commander)
end

function updateEnemy(dt)
    -- Move towards the player
    enemy.pos = enemy.pos + ((commander.pos - enemy.pos):normalized() * dt * enemy.speed)
    sprite.registerPosition(enemy)
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



