local leftPortrait = {x = 15, y = 340, w = 100, h = 125,
                      sx = -1, sy = 1, ox = 180, oy = 70}
leftPortrait.stencil = love.graphics.newStencil(function()
   love.graphics.rectangle("fill", leftPortrait.x, leftPortrait.y,
                           leftPortrait.w, leftPortrait.h)
end)

local rightPortrait = {x = 525, y = 340, w = 100, h = 125,
                       sx = 1, sy = 1, ox = 80, oy = 70}
rightPortrait.stencil = love.graphics.newStencil(function()
    love.graphics.rectangle("fill", rightPortrait.x, rightPortrait.y,
                            rightPortrait.w, rightPortrait.h)
end)

function drawPortrait(sprite, portrait)
    love.graphics.setStencil(portrait.stencil)
    love.graphics.rectangle("fill", 0, 0, 640, 480)
    love.graphics.draw(sprite.image, portrait.x, portrait.y,
        portrait.r, portrait.sx, portrait.sy, portrait.ox, portrait.oy)
    love.graphics.setStencil()
end

function lineIterator(text)
    return text:gmatch('(.-)\n()')
end

local Dialogue = {}

function loadDialogue(name)
    return love.filesystem.read("dialogue/"..name..".txt")
end

function Dialogue:enter(prevState, name, left, right, nextState, ...)
    audio.stop()
    local script = loadDialogue(name)
    self.script = lineIterator(script)
    self.left = left
    self.right = right
    self.nextState = nextState or prevState
    self.nextStateArgs = {...}
    self.currentLine = self.script()
end

function Dialogue:keyreleased(key)
    if key == "return" then
        self.currentLine = self.script()
        if not self.currentLine then
            Gamestate.switch(self.nextState, unpack(self.nextStateArgs))
        end
    end
end

function Dialogue:draw()
    drawPortrait(self.left, leftPortrait)
    drawPortrait(self.right, rightPortrait)
    if self.currentLine then
        love.graphics.print(self.currentLine, 150, 430)
    end
end

return {
    state = Dialogue,
}