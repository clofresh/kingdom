local battleCount = 0
local Battle = {name='battle'}

function Battle:enter(prevState, leftArmy, rightArmy, nextState)
    print(string.format("Transitioning from %s to %s",
        prevState.name or "nil", self.name))

    battleCount = battleCount + 1
    audio.play(audio.songs.theme2)
    self.round = 1
    self.index = sprite.SpatialIndex(32, 32)
    self.onScreen = {
        left  = sprite.SpatialIndex(640, 480),
        right = sprite.SpatialIndex(640, 480),
    }

    -- Lay out the troops on the battlefield
    local units = {}
    local active = {}
    local teams = {left={}, right={}}
    local leftDeploment = 0
    local rightDeploment = 0
    local x, xDelta, y, yDelta
    x = 200
    xDelta = 200
    y = 10
    yDelta = 100
    local team = 'left'
    for i, troop in pairs(leftArmy.troops) do
        troop.sx = -1/4
        troop.sy = 1/4
        troop.pos = vector(x, y)
        troop.tactic = 'advance'
        troop.team = team
        table.insert(units, troop)
        local index = #units
        table.insert(active, index)
        teams[team][index] = index
        y = y + yDelta
        leftDeploment = leftDeploment + 1
    end
    print(leftArmy.name .. " has " .. leftDeploment .. " troops")

    x = x + xDelta
    y = 10
    team = 'right'
    for i, troop in pairs(rightArmy.troops) do
        troop.sx = 1/4
        troop.sy = 1/4
        troop.pos = vector(x, y)
        troop.team = team
        table.insert(units, troop)
        local index = #units
        table.insert(active, index)
        teams[team][index] = index
        y = y + yDelta
        rightDeploment = rightDeploment + 1
    end
    print(rightArmy.name .. " has " .. rightDeploment .. " troops")

    self.units = units
    self.active = active
    self.teams = teams
    self.leftArmy = leftArmy
    self.rightArmy = rightArmy
    self.nextState = nextState or prevState
    self.winner = nil
    self.tactic = nil
end

function Battle:update(dt)
    -- Clear out defeated units
    local stillActive = {}
    local teamCounts = {left=0, right=0}
    for i, index in pairs(self.active) do
        local unit = self.units[index]
        if unit.health <= 0 then
            self.units[index] = nil
            self.teams[unit.team][index] = nil
            print(unit.name .. " is dead")
        else
            table.insert(stillActive, index)
            teamCounts[unit.team] = teamCounts[unit.team] + 1
        end
    end

    -- Set tactics
    for i, index in pairs(stillActive) do
        local unit = self.units[index]
        local target, targetDistanceVec = self:findClosestEnemy(unit)
        if targetDistanceVec == nil then
            unit.tactic = 'halt'
        elseif unit.tactic == 'advance' and targetDistanceVec:len() < 10 then
            unit.tactic = 'randomWalk'
        elseif unit.tactic == 'randomWalk' and targetDistanceVec:len() >= 10 then
            unit.tactic = 'advance'
        end
    end
    if #self.teams.left == 1 and #self.teams.right > 1 then
        for i, index in pairs(self.teams.left) do
            self.units[index].tactic = 'retreat'
        end
    end

    -- Resolve unit movement
    for i, index in pairs(stillActive) do
        local unit = self.units[index]
        self:unitTactic(unit, dt)
        self.index:registerPos(unit)
        self.onScreen[unit.team]:registerPos(unit)
    end

    -- Resolve unit attacks
    for i, index in pairs(stillActive) do
        local unit = self.units[index]
        self:unitAttack(unit, dt)
    end
    self.index:clear()

    -- Check for winning conditions
    if teamCounts.right == 0 then
        print(self.leftArmy.name .. " defeated " .. self.rightArmy.name
              .. " in battle " .. battleCount)
        Gamestate.switch(self.nextState, self.leftArmy, self.rightArmy)
    elseif teamCounts.left == 0 then
        print(self.rightArmy.name .. " defeated " .. self.leftArmy.name
              .. " in battle " .. battleCount)
        Gamestate.switch(self.nextState, self.rightArmy, self.leftArmy)
    elseif not self.onScreen.left:inBounds() then
        print(self.leftArmy.name .. " retreated from " .. self.rightArmy.name
              .. " in battle " .. battleCount)
        Gamestate.switch(self.nextState, self.rightArmy, nil)
    elseif not self.onScreen.right:inBounds() then
        print(self.rightArmy.name .. " retreated from " .. self.leftArmy.name
              .. " in battle " .. battleCount)
        Gamestate.switch(self.nextState, self.leftArmy, nil)
    end

    self.onScreen.left:clear()
    self.onScreen.right:clear()
    self.active = stillActive
    self.round = self.round + 1
end

function Battle:leave()
    self.rightArmy.lastBattle = love.timer.getTime()
    self.leftArmy.lastBattle = love.timer.getTime()
end

function Battle:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 0, 0, 640, 480)
    for i, index in pairs(self.active) do
        sprite.draw(self.units[index])
    end
end

function Battle:unitTactic(unit, dt)
    local tactic = unit.tactic or 'halt'
    return tactics[tactic](self, unit, dt)
end

function Battle:unitAttack(unit, dt)
    local target, targetDistanceVec = self:findClosestEnemy(unit)
    if target and targetDistanceVec:len() < 5 and math.random() > 0.5 then
        local damage = 1
        target.health = target.health - damage
        print(string.format("R%d - [%s] %s hits [%s] %s for %d, %d health left", self.round, unit.team, unit.name, target.team, target.name, damage, target.health))
    end
    return
end

function Battle:keyreleased(key)
    if key == 'a' then
        for i, index in pairs(self.teams.right) do
            self.units[index].tactic = 'advance'
        end
    elseif key == 'h' then
        for i, index in pairs(self.teams.right) do
            self.units[index].tactic = 'halt'
        end
    elseif key == 'r' then
        for i, index in pairs(self.teams.right) do
            self.units[index].tactic = 'retreat'
        end
    end
end

function Battle:findClosestEnemy(unit)
    local target, targetDistance, targetDistanceVec
    local newTargetDistance, newTargetDistanceVec
    local enemies, enemy
    if unit.team == 'left' then
        enemies = self.teams.right
    else
        enemies = self.teams.left
    end
    -- Find the closest enemy
    for i, index in pairs(enemies) do
        enemy = self.units[index]
        newTargetDistanceVec = enemy.pos - unit.pos
        newTargetDistance = newTargetDistanceVec:len()
        if target == nil or newTargetDistance < targetDistance then
            target = enemy
            targetDistance = newTargetDistance
            targetDistanceVec = newTargetDistanceVec
        end
    end
    return target, targetDistanceVec
end


return {
    state = Battle,
}