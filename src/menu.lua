local Menu = Class{__includes=context.Context,
    init = function(self, name, pos, options, selectedIndex)
        self.name = name
        self.pos = pos
        self.options = options
        self.selectedIndex = selectedIndex or 1
    end}

function Menu:load()
    love.keyreleased = function(key)
        if key == "escape" then
            context:pop()
        elseif key == "w" then
            self:selectPrev()
        elseif key == "s" then
            self:selectNext()
        elseif key == "return" then
            print("Selected " .. self:selectedOption().name)
            context.pop()
        end
    end
end

function Menu:selectedOption()
    return self.options[self.selectedIndex]
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
    Menu = Menu,
}