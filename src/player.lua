player = {
    score = 100,
    multipler = 1,
    ammo = 6,
    max_ammo = 6,
    health = 6,
    max_health = 6,
    take_damage = function(self)
        print("taking damage")
        self.health = math.clamp(0, self.health - 1, self.max_health)
        show_hurt = 0
        show_hurt = 2
        PlayerHit(bhit_container)
    end
}
