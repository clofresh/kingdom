local ATL = require("lib/Advanced-Tiled-Loader").Loader
Class = require "lib/hump/class"
vector = require "lib/hump/vector"
ATL.path = "maps/"

ContextStack = require("src/context").ContextStack
dialogue = require("src/dialogue")
sprite = require("src/sprite")

local map
local contextStack
local images = {}

local battle = Context("battle")
battle.isFullScreen = true
battle.load = function(self)
    self.index = sprite.SpatialIndex(32, 32)
    self.playerArmy = {
        {
            name = "Alistair",
            image = images.commander,
            pos = vector(400, 10),
            sx = 1/4,
            sy = 1/4,
            speed = 20,
            health = 10,
        },
        {
            name = "Lans",
            image = images.commander,
            pos = vector(400, 110),
            sx = 1/4,
            sy = 1/4,
            speed = 20,
            health = 10,
        },
        {
            name = "Gareth",
            image = images.commander,
            pos = vector(400, 210),
            sx = 1/4,
            sy = 1/4,
            speed = 20,
            health = 10,
        }
    }
    self.enemyArmy = {
        {
            name = "Laranjinha",
            image = images.commander,
            pos = vector(200, 10),
            sx = -1/4,
            sy = 1/4,
            speed = 20,
            health = 10,
        },
        {
            name = "Acerola",
            image = images.commander,
            pos = vector(200, 110),
            sx = -1/4,
            sy = 1/4,
            speed = 20,
            health = 10,
        }
    }
    self.winner = ''
end

battle.unload = function(self)
    print(self.winner .. " won the battle")
end

battle.update = function(self, dt)
    for i, unit in pairs(self.enemyArmy) do
        local target = nil
        local targetDistance = nil
        for i, foe in pairs(self.playerArmy) do
            if target == nil then
                target = foe
                targetDistance = (foe.pos - unit.pos):len()
            else
                local newTargetDistance = (foe.pos - unit.pos):len()
                if newTargetDistance < targetDistance then
                    target = foe
                    targetDistance = newTargetDistance
                end
            end
        end
        if target then
            local move = (target.pos - unit.pos):normalize_inplace() 
                           * (unit.speed * dt)
            unit.pos = unit.pos + move
        end
        self.index:registerPos(unit)
    end
    for i, unit in pairs(self.playerArmy) do
        self.index:registerPos(unit)
    end
    self.index:checkCollisions(dt, function(dt, sprites)
        for i, sprt0 in pairs(sprites) do
            for i, sprt1 in pairs(sprites) do
                if sprt0 ~= sprt1 and math.random() > 0.5 then
                    print(sprt0.name .. " hits " .. sprt1.name)
                    sprt1.health = sprt1.health - 1
                end
            end
        end
    end)
    self.index:clear()
    for i, unit in pairs(self.playerArmy) do
        if unit.health <= 0 then
            self.playerArmy[i] = nil
        end
    end
    for i, unit in pairs(self.enemyArmy) do
        if unit.health <= 0 then
            self.enemyArmy[i] = nil
        end
    end
    if #self.playerArmy == 0 then
        self.winner = 'enemy'
        contextStack:pop()
    elseif #self.enemyArmy == 0 then
        self.winner = 'player'
        contextStack:pop()
    end
end

battle.draw = function(self)
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 0, 0, 640, 480)
    for i, player in pairs(self.playerArmy) do
        sprite.draw(player)
    end
    for i, enemy in pairs(self.enemyArmy) do
        sprite.draw(enemy)
    end
end

local greetings = Context("greetings")

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
                contextStack:replace(battle)
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

local overworld = Context("overworld")
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
    local xPos, yPos
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
    contextStack = ContextStack({overworld})
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
        for i, context in pairs(contextStack.contexts) do
            context:draw()
        end
    end
end



