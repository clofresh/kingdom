-- third-party helper libraries
Gamestate = require "lib/hump/gamestate"
Class     = require "lib/hump/class"
vector    = require "lib/hump/vector"

-- kingdom context modules
battle    = require "src/battle"
overworld = require "src/overworld"

-- kingdom libraries
menu      = require "src/menu"
audio     = require "src/audio"
dialogue  = require "src/dialogue"
images    = require "src/images"
sprite    = require "src/sprite"
town      = require "src/town"

function love.load()
    audio.load()
    images.load()
    Gamestate.registerEvents()
    Gamestate.switch(overworld.state)
end

function love.draw()
    overworld.state:draw()
end
