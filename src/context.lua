local ContextStack = Class{function(self, contexts)
    self.contexts = {}
    for i, context in pairs(contexts) do
        self:push(context)
    end
end}

function ContextStack:pop()
    local context = table.remove(self.contexts)
    if context then
        print("Exiting " .. context.name)
        context:unload()
    end
    if #self.contexts == 0 then
        love.event.quit()
    else
        self:peek():reenter(context)
    end
end

function ContextStack:push(context)
    print("Entering " .. context.name)
    context:load()
    table.insert(self.contexts, context)
end

function ContextStack:replace(newContext)
    local context = table.remove(self.contexts)
    if context then
        print("Exiting " .. context.name)
        context:unload()
    end
    print("Entering " .. newContext.name)
    newContext:load()
    table.insert(self.contexts, newContext)
end

function ContextStack:peek()
    return self.contexts[#self.contexts]
end

local Context = Class{function(self, name)
    self.name = name
end}

function Context:load()
end

function Context:unload()
end

function Context:reenter(exitingContext)
end

function Context:update(dt)
end

function Context:draw()
end

return {
    ContextStack = ContextStack,
    Context = Context,
}