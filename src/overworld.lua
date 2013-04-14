local ATL = require("lib/Advanced-Tiled-Loader").Loader
ATL.path = "tmx/"

local Map = Class{function(self, player, name, song)
    self.map = ATL.load(name)
    self.map.drawObjects = false
    self.song = song
    self.index = sprite.SpatialIndex(32, 32)
    local enemies, playerStart = army.fromTmx(self.map('armies'))
    self.enemies = enemies
    player.pos = vector(playerStart.x, playerStart.y)
    self.player = player
    self.towns = town.fromTmx(self.map('towns'))
    self.collisionDetectors = {town.collide, battle.collide}
end}

function Map:update(dt)
    for i, twn in pairs(self.towns) do
        self.index:registerPos(twn)
    end
    self:updatePlayer(dt)
    self:updateEnemies(dt)
    self.index:checkCollisions(dt, function(dt, sprites)
        -- For now, assume that collisions only occur between 2 sprites
        local collider, collidee = unpack(sprites)
        self:collide(collider, collidee)
    end)
    self.index:clear()
end

function Map:updatePlayer(dt)
    if not self.player.defeated then
        if love.keyboard.isDown("w") then
            self.player.pos.y = self.player.pos.y - 1
        elseif love.keyboard.isDown("s") then
            self.player.pos.y = self.player.pos.y + 1
        end

        if love.keyboard.isDown("a") then
            self.player.pos.x = self.player.pos.x - 1
            self.player.sx = 1/8
            self.player.ox = 0
        elseif love.keyboard.isDown("d") then
            self.player.pos.x = self.player.pos.x + 1
            self.player.sx = -1/8
            self.player.ox = 256
        end
        self.index:registerPos(self.player)
        if self.player.inTown then
            local neighbors = self.index:getNeighbors(self.player)
            if #neighbors == 1 then
                self.player.inTown = false
            end
        end
    end
end

function Map:updateEnemies(dt)
    for name, enemy in pairs(self.enemies) do
        if not enemy.defeated then
            if self.updateEnemy then
                self:updateEnemy(dt, enemy)
            end
            self.index:registerPos(enemy)
        end
    end
end

function Map:collide(collider, collidee, others)
    local collided = false
    for i, func in pairs(self.collisionDetectors) do
        collided = func(collider, collidee)
        if collided then
            break
        end
        collided = func(collidee, collider)
        if collided then
            break
        end
    end
end

function Map:addCollisionDetector(collisionDetector)
    table.insert(self.collisionDetectors, collisionDetector)
end

function Map:draw()
    self.map:draw()
    if not self.player.defeated then
        sprite.draw(self.player)
    end
    for name, enemy in pairs(self.enemies) do
        if not enemy.defeated then
            sprite.draw(enemy)
        end
    end
end

local Overworld = {name='overview'}

function Overworld:enter(prevState, stateInfo)
    print(string.format("Transitioning from %s to %s",
        prevState.name or "nil", self.name))
    audio.play(self.map.song)
end

function Overworld:update(dt)
    self.map:update(dt)
end

function Overworld:draw()
    self.map:draw()

    love.graphics.print(string.format(
[[Memory: %dKB
Pos: (%f, %f)
]],
    math.floor(collectgarbage("count")),
    self.map.player.pos.x, self.map.player.pos.y), 1, 1)
end

return {
    state = Overworld,
    Map = Map,
}