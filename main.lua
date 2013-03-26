local ATL = require("lib/Advanced-Tiled-Loader").Loader
ATL.path = "maps/"

local map
function love.load()
    map = ATL.load("kingdom.tmx")
end

function love.update(dt)
end

function love.draw()
    map:draw()
end



