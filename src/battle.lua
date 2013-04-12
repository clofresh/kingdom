local battleCount = 0
local Battle = {}

function Battle:enter(prevState, leftArmy, rightArmy, nextState)
    battleCount = battleCount + 1
    audio.play(audio.songs.theme2)
    self.index = sprite.SpatialIndex(32, 32)

    -- Lay out the troops on the battlefield
    local leftDeploment = {}
    local rightDeploment = {}
    local x, xDelta, y, yDelta
    x = 200
    xDelta = 200
    y = 10
    yDelta = 100
    for i, troop in pairs(leftArmy.troops) do
        troop.sx = -1/4
        troop.sy = 1/4
        troop.pos = vector(x, y)
        troop.tactic = advance
        table.insert(leftDeploment, troop)
        y = y + yDelta
    end

    x = x + xDelta
    y = 10
    for i, troop in pairs(rightArmy.troops) do
        troop.sx = 1/4
        troop.sy = 1/4
        troop.pos = vector(x, y)
        troop.tactic = halt
        table.insert(rightDeploment, troop)
        y = y + yDelta
    end

    self.leftDeploment = leftDeploment
    self.rightDeploment = rightDeploment
    self.leftArmy = leftArmy
    self.rightArmy = rightArmy
    self.nextState = nextState or prevState
    self.winner = nil
    self.tactic = nil
end

function Battle:update(dt)
    -- Resolve unit movement
    for i, unit in pairs(self.leftDeploment) do
        unit:tactic(dt, self.rightDeploment, self.leftDeploment)
        self.index:registerPos(unit)
    end
    for i, unit in pairs(self.rightDeploment) do
        unit:tactic(dt, self.leftDeploment, self.rightDeploment)
        self.index:registerPos(unit)
    end

    -- Resolve unit attacks
    self.index:checkCollisions(dt, function(dt, sprites)
        for i, sprt0 in pairs(sprites) do
            for i, sprt1 in pairs(sprites) do
                if sprt0 ~= sprt1 and math.random() > 0.5 then
                    print(sprt0.name .. " hits " .. sprt1.name)
                    sprt1.health = sprt1.health - 1
                end
            end
        end
    end)
    self.index:clear()

    -- Clear out defeated units
    for i, unit in pairs(self.leftDeploment) do
        if unit.health <= 0 then
            table.remove(self.leftDeploment, i)
            print(unit.name .. " is dead")
        end
    end
    for i, unit in pairs(self.rightDeploment) do
        if unit.health <= 0 then
            table.remove(self.rightDeploment, i)
            print(unit.name .. " is dead")
        end
    end

    -- Check for winning conditions
    if #self.rightDeploment == 0 then
        print(self.leftArmy.name .. " won battle " .. battleCount)
        Gamestate.switch(self.nextState, self.leftArmy, self.rightArmy)
    elseif #self.leftDeploment == 0 then
        print(self.rightArmy.name .. " won battle " .. battleCount)
        Gamestate.switch(self.nextState, self.rightArmy, self.leftArmy)
    end
end

function Battle:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 0, 0, 640, 480)
    for i, troop in pairs(self.leftDeploment) do
        sprite.draw(troop)
    end
    for i, troop in pairs(self.rightDeploment) do
        sprite.draw(troop)
    end
end

function advance(unit, dt, enemies, friends)
    local target = nil
    local targetDistance = nil

    -- Find the closest enemy
    for i, foe in pairs(enemies) do
        if target == nil then
            target = foe
            targetDistance = (foe.pos - unit.pos):len()
        else
            local newTargetDistance = (foe.pos - unit.pos):len()
            if newTargetDistance < targetDistance then
                target = foe
                targetDistance = newTargetDistance
            end
        end
    end
    if target then
        local move = (target.pos - unit.pos):normalize_inplace()
                       * (unit.speed * dt)
        unit.pos = unit.pos + move
    end
end

function halt(unit, dt, enemies, friends)
end

function retreat(unit, dt, enemies, friends)
    local target = nil
    local targetDistance = nil

    -- Find the closest enemy
    for i, foe in pairs(enemies) do
        if target == nil then
            target = foe
            targetDistance = (foe.pos - unit.pos):len()
        else
            local newTargetDistance = (foe.pos - unit.pos):len()
            if newTargetDistance < targetDistance then
                target = foe
                targetDistance = newTargetDistance
            end
        end
    end
    if target then
        local move = (target.pos - unit.pos):normalize_inplace()
                       * (unit.speed * dt)
        unit.pos = unit.pos - move
    end
end

function Battle:keyreleased(key)
    if key == 'a' then
        for i, unit in pairs(self.rightDeploment) do
            unit.tactic = advance
        end
    elseif key == 'h' then
        for i, unit in pairs(self.rightDeploment) do
            unit.tactic = halt
        end
    elseif key == 'r' then
        for i, unit in pairs(self.rightDeploment) do
            unit.tactic = retreat
        end
    end
end

return {
    state = Battle,
}