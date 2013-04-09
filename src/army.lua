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
}
