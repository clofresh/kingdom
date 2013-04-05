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

function draw(lSprite, rSprite, line)
    drawPortrait(lSprite, leftPortrait)
    drawPortrait(rSprite, rightPortrait)
    if line then
        love.graphics.print(line, 150, 430)
    end
end

function lineIterator(text)
    return text:gmatch('(.-)\n()')
end

return {
    draw = draw,
    lineIterator = lineIterator
}