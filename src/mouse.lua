
Mouse = Object:extend()

local RETICLE_SHEET = love.graphics.newImage("asset/image/reticle_sheet.png")
local reticle_frames = {
    love.graphics.newQuad(0, 0, 26, 28, RETICLE_SHEET),
}

function Mouse:new()
    self.x = x
    self.y = y
    --self.w = w
    --self.h = h
    self.hitbox = Hitbox(self, 0, 0, 14, 14, 10, 2)

end

function Mouse:update(x, y)
    -- local mx2 = math.floor((love.mouse.getX() - window.translateX) / window.scale + 0.5)
    -- local my2 = math.floor((love.mouse.getY() - window.translateY) / window.scale + 0.5)
    self.x = x
    self.y = y --love.mouse.getPosition()
    self.hitbox:update()
end

function Mouse:draw()
    self.hitbox:draw()
    love.graphics.draw(RETICLE_SHEET, reticle_frames[1], self.x, self.y)
end
