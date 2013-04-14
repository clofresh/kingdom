local MenuState = {name='menu'}

local Menu = Class{function(self, name, pos, options, selectedIndex)
    self.name = name
    self.pos = pos
    self.options = options
    self.selectedIndex = selectedIndex or 1
    self.shouldExit = false
end}

function Menu:selectPrev()
    self.selectedIndex = self.selectedIndex - 1
    if self.selectedIndex == 0 then
        self.selectedIndex = #self.options
    end
end

function Menu:selectNext()
    self.selectedIndex = self.selectedIndex + 1
    if self.selectedIndex > #self.options then
        self.selectedIndex = 1
    end
end

function Menu:execute(index)
    local index = index or self.selectedIndex
    local selected = self.options[index]
    print("Executing " .. selected.name)
    selected:execute(self)
end

function Menu:exit()
    self.activator = nil
    self.shouldExit = true
end

function Menu:draw()
    local w = 100
    local h = 50

    -- love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", self.pos.x, self.pos.y, w, h)

    love.graphics.setColor(0, 0, 0)
    local lineHeight = 15
    for i, option in pairs(self.options) do
        local displayName
        if i == self.selectedIndex then
            displayName = "* " .. option.name
        else
            displayName = option.name
        end
        love.graphics.printf(displayName, self.pos.x, 
            self.pos.y + (lineHeight * i), w)
    end
    love.graphics.setColor(255, 255, 255)
    love.graphics.setStencil()

end

local MenuOption = Class{function(self, name, execute)
    self.name = name
    self.execute = execute
end}

function MenuState:enter(prevState, menu, nextState)
    print(string.format("Transitioning from %s to %s",
        prevState.name or "nil", self.name))
    self.menu = menu
    self.nextState = nextState or prevState
end

function MenuState:keyreleased(key)
    if key == "escape" then
        self.menu:exit()
    elseif key == "w" then
        self.menu:selectPrev()
    elseif key == "s" then
        self.menu:selectNext()
    elseif key == "return" then
        self.menu:execute()
    end
end

function MenuState:update(dt)
    if self.menu.shouldExit then
        self.menu.shouldExit = false
        Gamestate.switch(self.nextState)
    end
end

function MenuState:draw()
    self.menu:draw()
end

return {
    state = MenuState,
    Menu = Menu,
    MenuOption = MenuOption,
}