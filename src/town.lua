local defaultOptions = {
    menu.MenuOption("Recruit", function(self, menu)
        print("Recruited")
        menu.activator:addTroop(army.Infantry())
        menu:exit()
    end),
    menu.MenuOption("Exit", function(self, menu)
        menu:exit()
    end),
}

local Town = Class{__includes=menu.Menu, init=function(self, ...)
    menu.Menu.init(self, ...)
    self.type = 'town'
end}

function fromTmx(townLayer)
    local towns = {}
    for i, obj in pairs(townLayer.objects) do
        local twn = Town(obj.name, vector(obj.x, obj.y), defaultOptions)
        table.insert(towns, twn)
        print(string.format("Loaded town %s at %s", twn.name, tostring(twn.pos)))
    end
    return towns
end

function collide(collider, collidee)
    local collided = false
    if collider.type == 'player' and collidee.type == 'town' then
        local player = collider
        local town = collidee
        if not player.inTown then
            player.inTown = true
            town.activator = player
            Gamestate.switch(menu.state, town)
        end
        collided = true
    end

    return collided
end

return {
    fromTmx = fromTmx,
    Town = Town,
    collide = collide,
}
