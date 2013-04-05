EventStack = Class{function(self, events)
    self.events = {}
    for i, event in pairs(events) do
        self:push(event)
    end
end}

function EventStack:pop()
    local event = table.remove(self.events)
    if event then
        print("Untriggering " .. event.name)
        event:unload()
    end
    return event
end

function EventStack:push(event)
    print("Triggering " .. event.name)
    event:load()
    table.insert(self.events, event)
end

function EventStack:peek(val)
    return self.events[#self.events]
end

Event = Class{function(self, name)
    self.name = name
end}

function Event:load()
end

function Event:unload()
end

function Event:update(dt)
end

function Event:draw()
end

return {
    EventStack = EventStack,
    Event = Event,
}