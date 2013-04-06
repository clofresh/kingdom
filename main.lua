local ATL = require("lib/Advanced-Tiled-Loader").Loader
Class = require "lib/hump/class"
vector = require "lib/hump/vector"
ATL.path = "maps/"

context = require("src/context")
dialogue = require("src/dialogue")
sprite = require("src/sprite")
battle = require("src/battle")

contextStack = nil
images = {}

local greetings = context.Context("greetings")

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
                contextStack:replace(battle.battle)
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

local overworld = context.Context("overworld")
overworld.isFullScreen = true
overworld.load = function(self)
    self.map = ATL.load("kingdom.tmx")
    self.index = sprite.SpatialIndex(32, 32)

    local commander = {
        image = images.commander,
        pos = vector(453, 257),
        sx = 1/8,
        sy = 1/8,
        ox = 0,
        oy = 0,
    }
    local enemy = {
        image = images.commander,
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

overworld.reenter = function(self, exitingContext)
    if exitingContext.name == 'battle' then
        if exitingContext.winner == 'player' then
            self.enemy = nil
        elseif exitingContext.winner == 'enemy' then
            self.commander = nil
        end
    end
end

overworld.update = function(self, dt)
    self:updatePlayer(dt)
    self:updateEnemy(dt)
    self.index:checkCollisions(dt, function(dt, sprites)
        for i, sprt in pairs(sprites) do
            if sprt.onCollision then
                contextStack:push(sprt.onCollision)
                sprt.onCollision = nil
            end
        end
    end)
    self.index:clear()
end

overworld.updatePlayer = function(self, dt)
    if self.commander then
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
        self.index:registerPos(self.commander)
    end
end

overworld.updateEnemy = function(self, dt)
    if self.enemy then
        -- Move towards the player
        if self.commander then
            local dir = (self.commander.pos - self.enemy.pos):normalized()
            self.enemy.pos = self.enemy.pos + (dir * dt * self.enemy.speed)
        end
        self.index:registerPos(self.enemy)
    end
end

overworld.draw = function(self)
    local xPos = -1
    local yPos = -1
    self.map:draw()
    if self.commander then
        sprite.draw(self.commander)
        xPos = self.commander.pos.x
        yPos = self.commander.pos.y
    end
    if self.enemy then
        sprite.draw(self.enemy)
    end

    love.graphics.print(string.format(
[[Memory: %dKB
Pos: (%f, %f)
]],
    math.floor(collectgarbage("count")),
    xPos, yPos), 1, 1)
end

function love.load()
    images.commander = love.graphics.newImage("units/commander.png")
    contextStack = context.ContextStack({overworld})
end

function love.update(dt)
    local currentContext = contextStack:peek()
    if currentContext then
        currentContext:update(dt)
    end
end

function love.draw()
    local top = contextStack:peek()
    if top.isFullScreen then
        top:draw()
    else
        for i, ctx in pairs(contextStack.contexts) do
            ctx:draw()
        end
    end
end



