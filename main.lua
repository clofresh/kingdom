-- third-party helper libraries
Class  = require "lib/hump/class"
vector = require "lib/hump/vector"

-- kingdom context modules
context   = require "src/context"
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
    context.load({overworld.ctx})
end

function love.update(dt)
    context.update(dt)
end

function love.draw()
    context.draw()
end



