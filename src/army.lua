local Commander = Class{function(self, name, image, pos)
    self.name = name
    self.image = image
    self.pos = pos
    self.troops = {}
end}

function Commander:addTroop(troop)
    table.insert(self.troops, troop)
end

local Infantry = Class{function(self, name, image)
    self.name = name or randomName()
    self.image = image or images.loaded.commander
    self.speed = 20
    self.health = 1
end}

function loadPlayer(name)
    local player = Commander(name, images.loaded.commander)
    player.sx = 1/8
    player.sy = 1/8
    player.ox = 0
    player.oy = 0
    player.lastBattle = love.timer.getTime()
    player.type = 'player'
    for i = 1, 3 do
        player:addTroop(Infantry())
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
    Commander = Commander,
    Infantry = Infantry,
    fromTmx = fromTmx,
    loadPlayer = loadPlayer,
}
