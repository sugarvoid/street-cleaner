player = {
    score = 0,
    multipler = 1,
    ammo = 6,
    max_ammo = 6,
    health = Health(6),
    take_damage = function(self)
        self.health.current = math.clamp(0, self.health.current - 1, self.health.max)
        show_hurt = 0
        show_hurt = 2
        PlayerHit(bhit_container)
    end
}
