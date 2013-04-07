local defaultOptions = {
    {name = "Recruit"},
    {name = "Exit"},
}

local Town = Class{__includes=menu.Menu}

function Town:onCollision(sprites)
    for i, spr in pairs(sprites) do
        if spr ~= self and not spr.inTown then
            spr.inTown = true
            context.push(self)
        end
    end
end

function fromTmx(obj)
    return Town(obj.name, vector(obj.x, obj.y), defaultOptions, 1)
end

return {
    fromTmx = fromTmx,
    Town = Town,
}
