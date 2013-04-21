local loaded = {}
function load()
    loaded.commander = love.graphics.newImage("units/commander.png")
    loaded.infantry = love.graphics.newImage("units/infantry.gif")
    loaded.archer = love.graphics.newImage("units/archer.gif")
    loaded.arrow = love.graphics.newImage("units/arrow.gif")
end

return {
    loaded = loaded,
    load = load,
}