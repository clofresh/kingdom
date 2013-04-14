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
    self.health = 100
end}

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
}
