Mouse = Object:extend()

local RETICLE_SHEET = love.graphics.newImage("asset/image/reticle_sheet.png")
local reticle_frames = {
    love.graphics.newQuad(0, 0, 26, 28, RETICLE_SHEET),
}

function Mouse:new()
    self.position = { x = 0, y = 0 }
    self.hitbox = Hitbox(self, 0, 0, 10, 10, 12, 4)
end

function Mouse:update(x, y)
    self.position.x = x - 16
    self.position.y = y - 6
    self.hitbox:update()
end

function Mouse:draw()
    self.hitbox:draw()
    love.graphics.draw(RETICLE_SHEET, reticle_frames[1], self.position.x, self.position.y)
end
