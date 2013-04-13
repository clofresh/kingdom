function advance(battle, unit, dt, enemies, friends)
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

function halt(battle, unit, dt, enemies, friends)
end

function retreat(battle, unit, dt, enemies, friends)
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

return {
    advance = advance,
    halt = halt,
    retreat = retreat,
}