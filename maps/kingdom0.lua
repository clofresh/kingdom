local Kingdom0 = Class{__includes=overworld.Map, init=function(self, player)
    overworld.Map.init(self, player, "kingdom0.tmx", audio.songs.theme1)
    self:addCollisionDetector(collide)
end}

function Kingdom0:updateEnemy(dt, enemy)
    if enemy.name == 'Madrugadao' then
        local dir = (self.player.pos - enemy.pos):normalized()
        enemy.pos = enemy.pos + (dir * dt * enemy.speed)
    end
end

function collide(collider, collidee)
    if collider.name == 'Madrugadao' and collidee.type == 'player' then
        local madrugadao = collider
        local player = collidee
        if madrugadao.greeted then
            return battle.collide(collider, collidee)
        else
            local hello = dialogue.Dialogue("hello_world", madrugadao, player)
            Gamestate.switch(
                dialogue.state, hello,
                battle.state, battle.Battle(madrugadao, player),
                overworld.state)
            madrugadao.greeted = true
            return true
        end
    else
        return false
    end
end

return {
    map = Kingdom0,
}