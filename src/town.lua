local defaultOptions = {
    menu.MenuOption("Recruit", function(self, menu)
        print("Recruited")
        menu.activator:addTroop(army.Infantry())
        Gamestate.switch(menu.nextState, self)
    end),
    menu.MenuOption("Exit", function(self, menu)
        Gamestate.switch(menu.nextState, self)
    end),
}

local Town = Class{function(self, name, pos, options)
    self.name = name
    self.pos = pos
    self.options = options or defaultOptions
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

return {
    fromTmx = fromTmx,
    Town = Town,
}
