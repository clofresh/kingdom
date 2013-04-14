local Commander = Class{function(self, name, image, pos)
    self.name = name
    self.image = image
    self.pos = pos
    self.troops = {}
end}

function Commander:addTroop(troop)
    table.insert(self.troops, troop)
end

local Unit = Class{function(self, name, image)
    self.name = name or randomName()
    self.image = image or images.loaded.commander
    self.speed = 0
    self.health = 1
end}

function Unit:attack(battle, dt)
    local target, targetDistanceVec = battle:findClosestEnemy(self)
    if target and targetDistanceVec:len() < self.range and math.random() > 0.5 then
        target.health = target.health - self.damage
        print(string.format("R%d - [%s] %s hits [%s] %s for %d, %d health left", battle.round, self.team, self.name, target.team, target.name, self.damage, target.health))
    end
end

local Infantry = Class{__includes=Unit, init=function(self, name, image)
    local image = image or images.loaded.infantry
    Unit.init(self, name, image)
    self.speed = 20
    self.health = 10
    self.damage = 1
    self.range = 5
end}

local Archer = Class{__includes=Unit, init=function(self, name, image)
    local image = image or images.loaded.archer
    Unit.init(self, name, image)
    self.speed = 25
    self.health = 5
    self.damage = 1
    self.range = 100
end}

function loadPlayer(name)
    local player = Commander(name, images.loaded.commander)
    player.sx = 1/8
    player.sy = 1/8
    player.ox = 0
    player.oy = 0
    player.lastBattle = love.timer.getTime()
    player.type = 'player'
    for i = 1, 5 do
        player:addTroop(Archer())
    end
    return player
end

function fromTmx(armyLayer)
    local playerStart
    local enemies = {}
    for i, obj in pairs(armyLayer.objects) do
        if obj.type == "Commander" then
            local enemy = Commander(obj.name,
                images.loaded[obj.properties.image], vector(obj.x, obj.y))
            enemy.sx = -1/8
            enemy.sy = 1/8
            enemy.ox = 256
            enemy.oy = 0
            enemy.speed = obj.properties.speed
            enemy.lastBattle = love.timer.getTime()
            for i = 1, obj.properties.numTroops do
                enemy:addTroop(Infantry())
            end
            enemies[enemy.name] = enemy
        elseif obj.type == "PlayerStart" then
            playerStart = obj
        end
    end
    assert(playerStart)
    return enemies, playerStart
end

local names = {}

function loadNames(filename)
    local contents, size = love.filesystem.read(filename)

    local count = 1
    for line in contents:gmatch('(.-)\n()') do
      table.insert(names, line)
      count = count + 1
    end
    print("Loaded " .. count .. " names from " .. filename)

    return names
end

function randomName()
    return names[math.random(1, #names)]
end

return {
    loadNames = loadNames,
    randomName = randomName,
    fromTmx = fromTmx,
    loadPlayer = loadPlayer,
    Commander = Commander,
    Infantry = Infantry,
    Archer = Archer,
}
