-- third-party helper libraries
Gamestate = require "lib/hump/gamestate"
Class     = require "lib/hump/class"
vector    = require "lib/hump/vector"

-- kingdom libraries
tactics   = require "src/tactics"
battle    = require "src/battle"
overworld = require "src/overworld"
menu      = require "src/menu"
audio     = require "src/audio"
dialogue  = require "src/dialogue"
images    = require "src/images"
sprite    = require "src/sprite"
town      = require "src/town"
army      = require "src/army"

-- individual maps
local kingdom0 = require "maps/kingdom0"

function love.load()
    audio.load()
    images.load()
    army.loadNames("names/american.txt")
    local player = army.loadPlayer("Mormont")
    overworld.state.map = kingdom0.map(player)
    Gamestate.registerEvents()
    Gamestate.switch(overworld.state)
end

function love.draw()
    overworld.state:draw()
end
