ContextStack = Class{function(self, contexts)
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
    return context
end

function ContextStack:push(context)
    print("Entering " .. context.name)
    context:load()
    table.insert(self.contexts, context)
end

function ContextStack:peek(val)
    return self.contexts[#self.contexts]
end

Context = Class{function(self, name)
    self.name = name
end}

function Context:load()
end

function Context:unload()
end

function Context:update(dt)
end

function Context:draw()
end

return {
    ContextStack = ContextStack,
    Context = Context,
}