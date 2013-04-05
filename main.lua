local ATL = require("lib/Advanced-Tiled-Loader").Loader
Class = require "lib/hump/class"
vector = require "lib/hump/vector"
ATL.path = "maps/"

EventStack = require("src/event").EventStack
dialogue = require("src/dialogue")
sprite = require("src/sprite")

local map
local eventStack

local battle = Event("battle")
battle.load = function(self)
    self.timer = 10
end

battle.update = function(self, dt)
    self.timer = self.timer - dt
    if self.timer <= 0 then
        eventStack:pop()
    end
end

local greetings = Event("greetings")

greetings.load = function(self)
    local script = [[Commander: Ahoy there!
Enemy: Sup!
Commander: Not much.
Enemy: Aiight.
]]
    self.script = dialogue.lineIterator(script)
    self.currentLine = self.script()

    love.keyreleased = function(key)
        if key == "return" then
            self.currentLine = self.script()
            if not self.currentLine then
                eventStack:pop()
                eventStack:push(battle)
            end
        end
    end

end

greetings.unload = function(self)
    love.keyreleased = nil
end

greetings.draw = function (self)
    dialogue.draw(self.left, self.right, self.currentLine)
end

local overworld = Event("overworld")
overworld.load = function(self)
    self.map = ATL.load("kingdom.tmx")

    local commander = {
        image = love.graphics.newImage("units/commander.png"),
        pos = vector(453, 257),
        sx = 1/8,
        sy = 1/8,
        ox = 0,
        oy = 0,
    }
    local enemy = {
        image = commander.image,
        pos = vector(162, 162),
        sx = -1/8,
        sy = 1/8,
        ox = 256,
        oy = 0,
        speed = 20,
    }
    greetings.right = commander
    greetings.left = enemy
    enemy.onCollision = greetings 
    self.commander = commander
    self.enemy = enemy
end

overworld.update = function(self, dt)
    self:updatePlayer(dt)
    self:updateEnemy(dt)
    sprite.checkCollisions(dt, function(sprites)
        for i, sprite in pairs(sprites) do
            if sprite.onCollision then
                eventStack:push(sprite.onCollision)
                sprite.onCollision = nil
            end
        end
    end)
end

overworld.updatePlayer = function(self, dt)
    if love.keyboard.isDown("w") then
        self.commander.pos.y = self.commander.pos.y - 1
    elseif love.keyboard.isDown("s") then
        self.commander.pos.y = self.commander.pos.y + 1
    end

    if love.keyboard.isDown("a") then
        self.commander.pos.x = self.commander.pos.x - 1
        self.commander.sx = 1/8
        self.commander.ox = 0
    elseif love.keyboard.isDown("d") then
        self.commander.pos.x = self.commander.pos.x + 1
        self.commander.sx = -1/8
        self.commander.ox = 256
    end
    sprite.registerPosition(self.commander)
end

overworld.updateEnemy = function(self, dt)
    -- Move towards the player
    local dir = (self.commander.pos - self.enemy.pos):normalized()
    self.enemy.pos = self.enemy.pos + (dir * dt * self.enemy.speed)
    sprite.registerPosition(self.enemy)
end

overworld.draw = function(self)
    self.map:draw()
    sprite.draw(self.commander)
    sprite.draw(self.enemy)

    love.graphics.print(string.format(
[[Memory: %dKB
Pos: (%f, %f)
]],
    math.floor(collectgarbage("count")),
    self.commander.pos.x,
    self.commander.pos.y), 1, 1)
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



