local names = {}

function loadNames(filename)
    local f = io.open(filename, "r")

    local count = 1
    while true do
      local line = f:read("*lines")
      if line == nil then break end
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
