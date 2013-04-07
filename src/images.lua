local loaded = {}
function load()
    loaded.commander = love.graphics.newImage("units/commander.png")
end

return {
    loaded = loaded,
    load = load,
}