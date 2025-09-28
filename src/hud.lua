
local ammo_container = love.graphics.newImage("asset/image/ammo_container.png")
local ac_position = {x = 168, y = 181}
local ammo_icon = love.graphics.newImage("asset/image/bullet.png")
local health_icon = love.graphics.newImage("asset/image/health_unit.png")

local HUD_TEXT_SHEET = love.graphics.newImage("asset/image/hud_text.png")

local health = love.graphics.newQuad(0, 0, 176, 30, HUD_TEXT_SHEET)
local focus = love.graphics.newQuad(0, 29, 176, 30, HUD_TEXT_SHEET)
local score = love.graphics.newQuad(0, 58, 176, 30, HUD_TEXT_SHEET)

local AMMO_STARTING_X = 180
local AMMO_Y = 194

hud = {
    draw = function(self)
        love.graphics.draw(HUD_TEXT_SHEET, score, 260, 190, 0, 0.2, 0.2)
        love.graphics.draw(HUD_TEXT_SHEET, health, 30, 189, 0, 0.2, 0.2)
        love.graphics.draw(HUD_TEXT_SHEET, focus, 30, 190 + 8, 0, 0.2, 0.2)
        love.graphics.draw(ammo_container, ac_position.x, ac_position.y)
        for i = 1, player.ammo do
            love.graphics.draw(ammo_icon, AMMO_STARTING_X + (8 * (i - 1)), AMMO_Y)
        end
        for i = 1, player.health do
            love.graphics.draw(health_icon, 75 + (7 * (i - 1)), 189)
        end
    end,
}
