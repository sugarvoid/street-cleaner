player = {
    score = 0,
    multipler = 1,
    ammo = 8,
    max_ammo = 8,
    health = Health(6),
    take_damage = function(self)
        self.health.current = math.clamp(0, self.health.current - 1, self.health.max)
        if self.health.current == 0 then
            
            change_gamestate(GAME_STATES.gameover)
        end
        show_hurt = 0
        show_hurt = 2
        PlayerHit(bhit_container)
    end
}
