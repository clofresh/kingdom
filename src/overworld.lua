local ATL = require("lib/Advanced-Tiled-Loader").Loader
ATL.path = "maps/"

local greetings = context.Context("greetings")

greetings.load = function(self)
    audio.stop()

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
                context.replace(battle.ctx)
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
    self.song = audio.songs.theme1
    audio.play(self.song)
    self.map = ATL.load("kingdom.tmx")
    self.map.drawObjects = false
    self.index = sprite.SpatialIndex(32, 32)

    local enemyStart, playerStart
    for i, obj in pairs(self.map("armies").objects) do
        if obj.name == "enemyStart" then
            enemyStart = obj
        elseif obj.name == "playerStart" then
            playerStart = obj
        end
    end
    assert(enemyStart)
    assert(playerStart)

    local commander = {
        image = images.loaded.commander,
        pos = vector(playerStart.x, playerStart.y),
        sx = 1/8,
        sy = 1/8,
        ox = 0,
        oy = 0,
    }
    local enemy = {
        image = images.loaded.commander,
        pos = vector(enemyStart.x, enemyStart.y),
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
    audio.play(self.song)
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
                context.push(sprt.onCollision)
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

return {
    ctx = overworld,
}