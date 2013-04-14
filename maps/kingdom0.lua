local Kingdom0 = Class{__includes=overworld.Map, init=function(self, player)
    overworld.Map.init(self, player, "kingdom0.tmx", audio.songs.theme1)
end}

function Kingdom0:updateEnemy(dt, enemy)
    if enemy.name == 'Madrugadao' then
        local dir = (self.player.pos - enemy.pos):normalized()
        enemy.pos = enemy.pos + (dir * dt * enemy.speed)
    end
end

function Kingdom0:collide(collider, collidee, others)
    if collider.name == 'Madrugadao' and collidee == self.player then
        if collider.greeted then
            if love.timer.getTime() - self.player.lastBattle > 5 then
                Gamestate.switch(
                    battle.state, battle.Battle(collider, collidee),
                    overworld.state)
            end
        else
            local hello = dialogue.Dialogue("hello_world", collider, collidee)
            Gamestate.switch(
                dialogue.state, hello,
                battle.state, battle.Battle(collider, collidee),
                overworld.state)
            collider.greeted = true
        end
    elseif collidee.name == 'Madrugadao' and collider == self.player then
    else
        overworld.Map.collide(self, collider, collidee, others)
    end
end

return {
    map = Kingdom0,
}