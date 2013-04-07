local stack

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

function load(initialContexts)
    stack = ContextStack(initialContexts)
    val = "blah"
end

function update(dt)
    -- update the context on top of the context stack, if any
    local currentContext = stack:peek()
    if currentContext then
        currentContext:update(dt)
    end
end

function draw()
    -- if the top of the context stack is full screen, just draw that,
    -- otherwise draw each context on the stack, in FIFO order
    local top = stack:peek()
    if top.isFullScreen then
        top:draw()
    else
        for i, ctx in pairs(stack.contexts) do
            ctx:draw()
        end
    end
end

function push(ctx)
    return stack:push(ctx)
end

function pop()
    return stack:pop()
end

function replace(ctx)
    return stack:replace(ctx)
end

return {
    ContextStack = ContextStack,
    Context = Context,
    load = load,
    update = update,
    draw = draw,
    push = push,
    pop = pop,
    replace = replace,
}