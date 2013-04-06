SpatialIndex = Class{function(self, xMod, yMod)
    self.xMod = xMod
    self.yMod = yMod
    self._positions = {}
end}

function SpatialIndex:registerPos(sprite)
    local x = math.floor(sprite.pos.x / self.xMod)
    local y = math.floor(sprite.pos.y / self.yMod)
    local positions = self._positions
    if not positions[x] then
        positions[x] = {[y] = {sprite}}
    elseif not positions[x][y] then
        positions[x][y] = {sprite}
    else
        table.insert(positions[x][y], sprite)
    end
end

function SpatialIndex:checkCollisions(dt, callback)
    for x, ys in pairs(self._positions) do
        for y, sprites in pairs(ys) do
            if #sprites > 1 then
                callback(dt, sprites)
            end
        end
    end
end

function SpatialIndex:clear()
    self._positions = {}
end

function draw(sprite)
    love.graphics.draw(sprite.image, sprite.pos.x, sprite.pos.y,
        sprite.r, sprite.sx, sprite.sy,
        sprite.ox, sprite.oy)
end

return {
    draw = draw,
    SpatialIndex = SpatialIndex,
}