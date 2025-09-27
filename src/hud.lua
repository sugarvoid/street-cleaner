
local ammo_container = love.graphics.newImage("asset/image/ammo_container.png")
local ac_position = {x = 168, y = 181}
local ammo_icon = love.graphics.newImage("asset/image/bullet.png")

local AMMO_STARTING_X = 180
local AMMO_Y = 194

hud = {
    draw = function(self)
        love.graphics.draw(ammo_container, ac_position.x, ac_position.y)
        for i = 1, player.ammo do
            love.graphics.draw(ammo_icon, AMMO_STARTING_X + (8 * (i - 1)), AMMO_Y)
        end
    end,
}
