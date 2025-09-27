
local ammo_container = love.graphics.newImage("asset/image/ammo_container.png")
local ac_position = {x=168, y=181}

hud = {
    draw=function(self)
        love.graphics.draw(ammo_container, ac_position.x, ac_position.y)
    end,
}