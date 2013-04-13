function findClosest(unit, neighbors)
    local target, targetDistance, targetDistanceVec
    local newTargetDistance, newTargetDistanceVec
    -- Find the closest enemy
    for i, neighbor in pairs(neighbors) do
        newTargetDistanceVec = neighbor.pos - unit.pos
        newTargetDistance = newTargetDistanceVec:len()
        if target == nil or newTargetDistance < targetDistance then
            target = neighbor
            targetDistance = newTargetDistance
            targetDistanceVec = newTargetDistanceVec
        end
    end
    return target, targetDistanceVec
end

function moveTowards(unit, direction, dt)
    unit.pos = unit.pos + direction:normalize_inplace() * (unit.speed * dt)
end

function advance(battle, unit, dt, enemies, friends)
    local target, targetDistanceVec = findClosest(unit, enemies)
    if target then
        moveTowards(unit, targetDistanceVec, dt)
    end
end

function halt(battle, unit, dt, enemies, friends)
end

function retreat(battle, unit, dt, enemies, friends)
    local target, targetDistanceVec = findClosest(unit, enemies)
    if target then
        moveTowards(unit, -targetDistanceVec, dt)
    end
end

return {
    advance = advance,
    halt = halt,
    retreat = retreat,
}