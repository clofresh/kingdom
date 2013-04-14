local battleCount = 0
local BattleState = {name='battle'}

local Battle = Class{function(self, leftArmy, rightArmy, name)
    self.leftArmy = leftArmy
    self.rightArmy = rightArmy
    self.name = name
    self.winner = nil
    self.loser = nil
end}

function Battle:touchLastBattle(timestamp)
    local timestamp = timestamp or love.timer.getTime()
    self.rightArmy.lastBattle = timestamp
    self.leftArmy.lastBattle = timestamp
end

function Battle:formatResult()
    if self.winner and self.loser then
        return self.winner.name .. " defeated " .. self.loser.name
              .. " in " .. self.name
    elseif self.winner then
        return self.loser.name .. " retreated from " .. self.name
    else
        return self.name .. " ended"
    end
end

function BattleState:enter(prevState, battle, nextState)
    print(string.format("Transitioning from %s to %s",
        prevState.name or "nil", self.name))
    self.battle = battle
    local leftArmy = battle.leftArmy
    local rightArmy = battle.rightArmy
    battleCount = battleCount + 1
    if not battle.name then
        battle.name = 'battle ' .. battleCount
    end
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
    for i, troop in pairs(self.battle.leftArmy.troops) do
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
    for i, troop in pairs(self.battle.rightArmy.troops) do
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
    self.nextState = nextState or prevState
    self.winner = nil
    self.tactic = nil
end

function BattleState:update(dt)
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
    local exiting = false
    if teamCounts.right == 0 then
        self.battle.winner = self.battle.leftArmy
        self.battle.loser = self.battle.rightArmy
        exiting = true
    elseif teamCounts.left == 0 then
        self.battle.winner = self.battle.rightArmy
        self.battle.loser = self.battle.leftArmy
        exiting = true
    elseif not self.onScreen.left:inBounds() then
        self.battle.winner = self.battle.rightArmy
        self.battle.loser = nil
        exiting = true
    elseif not self.onScreen.right:inBounds() then
        self.battle.winner = self.battle.leftArmy
        self.battle.loser = nil
        exiting = true
    end
    if exiting then
        Gamestate.switch(self.nextState, self.battle)
    end
    self.onScreen.left:clear()
    self.onScreen.right:clear()
    self.active = stillActive
    self.round = self.round + 1
end

function BattleState:leave()
    print(self.battle:formatResult())
    self.battle:touchLastBattle()
    if self.battle.loser then
        self.battle.loser.defeated = true
    end
end

function BattleState:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 0, 0, 640, 480)
    for i, index in pairs(self.active) do
        sprite.draw(self.units[index])
    end
end

function BattleState:unitTactic(unit, dt)
    local tactic = unit.tactic or 'halt'
    return tactics[tactic](self, unit, dt)
end

function BattleState:unitAttack(unit, dt)
    local target, targetDistanceVec = self:findClosestEnemy(unit)
    if target and targetDistanceVec:len() < 5 and math.random() > 0.5 then
        local damage = 1
        target.health = target.health - damage
        print(string.format("R%d - [%s] %s hits [%s] %s for %d, %d health left", self.round, unit.team, unit.name, target.team, target.name, damage, target.health))
    end
    return
end

function BattleState:keyreleased(key)
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

function BattleState:findClosestEnemy(unit)
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

function collide(collider, collidee)
    if collidee.type == 'player' and collider.troops then
        local player, enemy
        player = collidee
        enemy = collider
        if love.timer.getTime() - player.lastBattle > 5
        and not player.defeated and not enemy.defeated then
            Gamestate.switch(BattleState, Battle(enemy, player), Overworld)
            return true
        else
            return false
        end
    else
        return false
    end
end

return {
    state = BattleState,
    Battle = Battle,
    collide = collide,
}