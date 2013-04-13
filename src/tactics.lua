function moveTowards(unit, direction, dt)
    unit.pos = unit.pos + direction:normalize_inplace() * (unit.speed * dt)
end

function randomVector()
    return vector(math.random() - 0.5, math.random() - 0.5)
end

function advance(battle, unit, dt)
    local target, targetDistanceVec = battle:findClosestEnemy(unit)
    if target then
        moveTowards(unit, targetDistanceVec, dt)
    end
end

function halt(battle, unit, dt)
end

function retreat(battle, unit, dt)
    local target, targetDistanceVec = battle:findClosestEnemy(unit)
    if target then
        moveTowards(unit, -targetDistanceVec, dt)
    end
end

function randomWalk(battle, unit, dt)
    moveTowards(unit, randomVector(), dt)
end

return {
    advance = advance,
    halt = halt,
    retreat = retreat,
    randomWalk = randomWalk,
}