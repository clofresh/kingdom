local ATL = require("lib/Advanced-Tiled-Loader").Loader
ATL.path = "maps/"

local Overworld = {name="overworld"}
Overworld.isFullScreen = true
function Overworld:init()
    self.song = audio.songs.theme1
    audio.play(self.song)
    self.map = ATL.load("kingdom.tmx")
    self.map.drawObjects = false
    self.index = sprite.SpatialIndex(32, 32)
    self.towns = {}

    local playerStart, enemy
    for i, obj in pairs(self.map("armies").objects) do
        if obj.name == "Madrugadao" then
            enemy = army.Commander(obj.name,
                images.loaded[obj.properties.image], vector(obj.x, obj.y))
            enemy.sx = -1/8
            enemy.sy = 1/8
            enemy.ox = 256
            enemy.oy = 0
            enemy.speed = obj.properties.speed
            enemy.lastBattle = love.timer.getTime()
            for i = 1, obj.properties.numTroops do
                enemy:addTroop(army.Infantry())
            end

        elseif obj.name == "Player" then
            playerStart = obj
        end
    end
    assert(playerStart)

    for i, obj in pairs(self.map("towns").objects) do
        local twn = town.fromTmx(obj)
        table.insert(self.towns, twn)
        print("Loaded town: " .. twn.name)
    end

    local commander = army.Commander("Mormont", images.loaded.commander,
        vector(playerStart.x, playerStart.y))
    commander.sx = 1/8
    commander.sy = 1/8
    commander.ox = 0
    commander.oy = 0
    commander.lastBattle = love.timer.getTime()
    for i = 1, 3 do
        commander:addTroop(army.Infantry())
    end

    local script = [[Commander: Ahoy there!
Enemy: Sup!
Commander: Not much.
Enemy: Aiight.
]]
    enemy.onCollision = function(self, sprites)
        if self.greeted then
            if love.timer.getTime() - commander.lastBattle > 5 then
                Gamestate.switch(battle.state, enemy, commander, Overworld)
            end
        else
            Gamestate.switch(dialogue.state, "greetings", script, enemy, commander, battle.state, enemy, commander, Overworld)
            self.greeted = true
        end
    end
    self.commander = commander
    self.enemy = enemy
end

function Overworld:enter(prevState, ...)
    audio.play(self.song)
    if prevState == battle.state then
        local winner, loser = unpack({...})
        if loser then
            loser.defeated = true
        end
    end
end

function Overworld:update(dt)
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

function Overworld:updatePlayer(dt)
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

function Overworld:updateEnemy(dt)
    if not self.enemy.defeated then
        -- Move towards the player
        if self.commander then
            local dir = (self.commander.pos - self.enemy.pos):normalized()
            self.enemy.pos = self.enemy.pos + (dir * dt * self.enemy.speed)
        end
        self.index:registerPos(self.enemy)
    end
end

function Overworld:draw()
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
    state = Overworld,
}