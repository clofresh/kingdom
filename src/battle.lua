local battle = context.Context("battle")
battle.isFullScreen = true
battle.load = function(self)
    audio.play(audio.songs.theme2)
    self.index = sprite.SpatialIndex(32, 32)
    self.playerArmy = {
        {
            name = "Alistair",
            image = images.loaded.commander,
            pos = vector(400, 10),
            sx = 1/4,
            sy = 1/4,
            speed = 20,
            health = 10,
        },
        {
            name = "Lans",
            image = images.loaded.commander,
            pos = vector(400, 110),
            sx = 1/4,
            sy = 1/4,
            speed = 20,
            health = 10,
        },
        {
            name = "Gareth",
            image = images.loaded.commander,
            pos = vector(400, 210),
            sx = 1/4,
            sy = 1/4,
            speed = 20,
            health = 10,
        }
    }
    self.enemyArmy = {
        {
            name = "Laranjinha",
            image = images.loaded.commander,
            pos = vector(200, 10),
            sx = -1/4,
            sy = 1/4,
            speed = 20,
            health = 10,
        },
        {
            name = "Acerola",
            image = images.loaded.commander,
            pos = vector(200, 110),
            sx = -1/4,
            sy = 1/4,
            speed = 20,
            health = 10,
        }
    }
    self.winner = ''
end

battle.unload = function(self)
    print(self.winner .. " won the battle")
end

battle.update = function(self, dt)
    for i, unit in pairs(self.enemyArmy) do
        local target = nil
        local targetDistance = nil
        for i, foe in pairs(self.playerArmy) do
            if target == nil then
                target = foe
                targetDistance = (foe.pos - unit.pos):len()
            else
                local newTargetDistance = (foe.pos - unit.pos):len()
                if newTargetDistance < targetDistance then
                    target = foe
                    targetDistance = newTargetDistance
                end
            end
        end
        if target then
            local move = (target.pos - unit.pos):normalize_inplace() 
                           * (unit.speed * dt)
            unit.pos = unit.pos + move
        end
        self.index:registerPos(unit)
    end
    for i, unit in pairs(self.playerArmy) do
        self.index:registerPos(unit)
    end
    self.index:checkCollisions(dt, function(dt, sprites)
        for i, sprt0 in pairs(sprites) do
            for i, sprt1 in pairs(sprites) do
                if sprt0 ~= sprt1 and math.random() > 0.5 then
                    print(sprt0.name .. " hits " .. sprt1.name)
                    sprt1.health = sprt1.health - 1
                end
            end
        end
    end)
    self.index:clear()
    for i, unit in pairs(self.playerArmy) do
        if unit.health <= 0 then
            self.playerArmy[i] = nil
        end
    end
    for i, unit in pairs(self.enemyArmy) do
        if unit.health <= 0 then
            self.enemyArmy[i] = nil
        end
    end
    if #self.playerArmy == 0 then
        self.winner = 'enemy'
        context.pop()
    elseif #self.enemyArmy == 0 then
        self.winner = 'player'
        context.pop()
    end
end

battle.draw = function(self)
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 0, 0, 640, 480)
    for i, player in pairs(self.playerArmy) do
        sprite.draw(player)
    end
    for i, enemy in pairs(self.enemyArmy) do
        sprite.draw(enemy)
    end
end

return {
    ctx = battle,
}