local defaultOptions = {
    {
        name = "Recruit",
        execute = function(menu)
            print("Recruited")
            table.insert(menu.activator.troops, {
                name = "New Guy",
                image = images.loaded.commander,
                speed = 25,
                health = 100,
            })
            Gamestate.switch(menu.nextState, selected)
        end
    },
    {
        name = "Exit",
        execute = function(menu)
            Gamestate.switch(menu.nextState, selected)
        end
    },
}

local Town = Class{function(self, name, pos, options)
    self.name = name
    self.pos = pos
    self.options = options or defaultOptions
end}

function Town:onCollision(sprites)
    for i, spr in pairs(sprites) do
        if spr ~= self and not spr.inTown then
            spr.inTown = true
            Gamestate.switch(menu.state, spr, self.pos, self.options)
        end
    end
end

function fromTmx(obj)
    return Town(obj.name, vector(obj.x, obj.y), defaultOptions)
end

return {
    fromTmx = fromTmx,
    Town = Town,
}
