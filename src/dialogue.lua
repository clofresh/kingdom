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

local Dialogue = Class{function(self, name, left, right)
    self.name = name
    self.script = loadDialogue(name)
    self.left = left
    self.right = right
    self.currentLine = self.script()
end}

function Dialogue:advance()
    self.currentLine = self.script()
    return self.currentLine
end

function Dialogue:draw()
    drawPortrait(self.left, leftPortrait)
    drawPortrait(self.right, rightPortrait)
    if self.currentLine then
        love.graphics.print(self.currentLine, 150, 430)
    end
end

local DialogueState = {name='dialogue'}

function loadDialogue(name)
    return love.filesystem.read("dialogue/"..name..".txt"):gmatch('(.-)\n()')
end

function DialogueState:enter(prevState, dialogue, nextState, ...)
    print(string.format("Transitioning from %s to %s",
        prevState.name or "nil", self.name))
    audio.stop()
    self.dialogue = dialogue
    self.nextState = nextState or prevState
    self.nextStateArgs = {...}
end

function DialogueState:keyreleased(key)
    if key == "return" then
        local currentLine = self.dialogue:advance()
        if not currentLine then
            Gamestate.switch(self.nextState, unpack(self.nextStateArgs))
        end
    end
end

function DialogueState:draw()
    self.dialogue:draw()
end

return {
    state = DialogueState,
    Dialogue = Dialogue,
}