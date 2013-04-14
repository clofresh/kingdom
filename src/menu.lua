local Menu = {name='menu'}

function Menu:enter(prevState, activator, pos, options, selectedIndex,
                    nextState)
    print(string.format("Transitioning from %s to %s",
        prevState.name or "nil", self.name))

    self.activator = activator
    self.pos = pos
    self.options = options
    self.selectedIndex = selectedIndex or 1
    self.nextState = nextState or prevState
end

function Menu:keyreleased(key)
    if key == "escape" then
        Gamestate.switch(self.nextState)
    elseif key == "w" then
        self:selectPrev()
    elseif key == "s" then
        self:selectNext()
    elseif key == "return" then
        self:execute(self.selectedIndex, self.activator)
    end
end

function Menu:execute(selectedIndex, activator)
    local selected =  self.options[selectedIndex]
    print("Executing " .. selected.name)
    selected.execute(self)
end

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

return {
    state = Menu,
}