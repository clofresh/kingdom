local SpatialIndex = Class{function(self, xMod, yMod)
    self.xMod = xMod
    self.yMod = yMod
    self._positions = {}
end}

function SpatialIndex:getXY(sprite)
    local x = math.floor(sprite.pos.x / self.xMod)
    local y = math.floor(sprite.pos.y / self.yMod)
    return x, y
end

function SpatialIndex:registerPos(sprite)
    local x, y = self:getXY(sprite)
    local positions = self._positions
    if not positions[x] then
        positions[x] = {[y] = {sprite}}
    elseif not positions[x][y] then
        positions[x][y] = {sprite}
    else
        table.insert(positions[x][y], sprite)
    end
end

function SpatialIndex:getNeighbors(sprite)
    local x, y = self:getXY(sprite)
    local positions = self._positions
    if not positions[x] or not positions[x][y] then
        return {}
    else
        return positions[x][y]
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

function SpatialIndex:inBounds()
    for x, ys in pairs(self._positions) do
        if x ~= 0 then
            return false
        end
        for y, sprites in pairs(ys) do
            if y ~= 0 then
                return false
            end
        end
    end
    return true
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