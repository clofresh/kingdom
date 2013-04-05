local positions = {}

function draw(sprite)
    love.graphics.draw(sprite.image, sprite.pos.x, sprite.pos.y,
        sprite.r, sprite.sx, sprite.sy,
        sprite.ox, sprite.oy)
end

function checkCollisions(dt, callback)
    for x, ys in pairs(positions) do
        for y, sprites in pairs(ys) do
            if #sprites > 1 then
                callback(sprites)
            end
        end
    end
    positions = {}
end

function registerPosition(sprite)
    local x = math.floor(sprite.pos.x / 32)
    local y = math.floor(sprite.pos.y / 32)
    if not positions[x] then
        positions[x] = {[y] = {sprite}}
    elseif not positions[x][y] then
        positions[x][y] = {sprite}
    else
        table.insert(positions[x][y], sprite)
    end
end

return {
    draw = draw,
    checkCollisions = checkCollisions,
    registerPosition = registerPosition,
}