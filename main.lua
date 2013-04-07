Class = require "lib/hump/class"
vector = require "lib/hump/vector"

context = require("src/context")
dialogue = require("src/dialogue")
sprite = require("src/sprite")
battle = require("src/battle")
overworld = require("src/overworld")
audio = require("src/audio")
images = require("src/images")

contextStack = nil
currentSong = nil

function love.load()
    audio.load()
    images.load()
    contextStack = context.ContextStack({overworld.ctx})
end

function love.update(dt)
    local currentContext = contextStack:peek()
    if currentContext then
        currentContext:update(dt)
    end
end

function love.draw()
    local top = contextStack:peek()
    if top.isFullScreen then
        top:draw()
    else
        for i, ctx in pairs(contextStack.contexts) do
            ctx:draw()
        end
    end
end



