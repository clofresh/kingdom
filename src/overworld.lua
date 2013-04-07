local ATL = require("lib/Advanced-Tiled-Loader").Loader
ATL.path = "maps/"

local overworld = context.Context("overworld")
overworld.isFullScreen = true
overworld.load = function(self)
    self.song = audio.songs.theme1
    audio.play(self.song)
    self.map = ATL.load("kingdom.tmx")
    self.map.drawObjects = false
    self.index = sprite.SpatialIndex(32, 32)
    self.towns = {}

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

    for i, obj in pairs(self.map("towns").objects) do
        local twn = town.fromTmx(obj)
        table.insert(self.towns, twn)
        print("Loaded town: " .. twn.name)
    end

    local commander = {
        name = "Mormont",
        image = images.loaded.commander,
        pos = vector(playerStart.x, playerStart.y),
        sx = 1/8,
        sy = 1/8,
        ox = 0,
        oy = 0,
        troops = {
            {
                name = "Alistair",
                image = images.loaded.commander,
                speed = 20,
                health = 10,
            },
            {
                name = "Lans",
                image = images.loaded.commander,
                speed = 20,
                health = 10,
            },
            {
                name = "Gareth",
                image = images.loaded.commander,
                speed = 20,
                health = 10,
            },
        },
    }
    local enemy = {
        name = "Madrugadao",
        image = images.loaded.commander,
        pos = vector(enemyStart.x, enemyStart.y),
        sx = -1/8,
        sy = 1/8,
        ox = 256,
        oy = 0,
        speed = 20,
        troops = {
            {
                name = "Laranjinha",
                image = images.loaded.commander,
                speed = 20,
                health = 10,
            },
            {
                name = "Acerola",
                image = images.loaded.commander,
                speed = 20,
                health = 10,
            },
        },
    }

    local script = [[Commander: Ahoy there!
Enemy: Sup!
Commander: Not much.
Enemy: Aiight.
]]
    local greetings = dialogue.Dialogue("greetings", script, enemy, commander,
        battle.Battle(enemy, commander))
    enemy.onCollision = function(self, sprites)
        if not self.greeted then
            context.push(greetings)
            self.greeted = true
        end
    end
    self.commander = commander
    self.enemy = enemy
end

overworld.reenter = function(self, exitingContext)
    audio.play(self.song)
end

overworld.update = function(self, dt)
    for i, twn in pairs(self.towns) do
        self.index:registerPos(twn)
    end
    self:updatePlayer(dt)
    self:updateEnemy(dt)
    self.index:checkCollisions(dt, function(dt, sprites)
        for i, sprt in pairs(sprites) do
            if sprt.onCollision then
                sprt:onCollision(sprites)
            end
        end
    end)
    self.index:clear()
end

overworld.updatePlayer = function(self, dt)
    if not self.commander.defeated then
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
        if self.commander.inTown then
            local neighbors = self.index:getNeighbors(self.commander)
            if #neighbors == 1 then
                self.commander.inTown = false
            end
        end
    end
end

overworld.updateEnemy = function(self, dt)
    if not self.enemy.defeated then
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
    if not self.commander.defeated then
        sprite.draw(self.commander)
        xPos = self.commander.pos.x
        yPos = self.commander.pos.y
    end
    if not self.enemy.defeated then
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