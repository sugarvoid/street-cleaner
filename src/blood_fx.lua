
BloodFx = Object:extend()

local BLOOD_SPR = love.graphics.newImage("asset/image/blood_sheet.png")
local BLOOD_GRID = anim8.newGrid(32, 32, BLOOD_SPR:getWidth(), BLOOD_SPR:getHeight())

function BloodFx:new(x, y, container)
    self.x = x or 0
    self.y = y or 0
    self.parent = container
    self.animation = anim8.newAnimation(BLOOD_GRID(('1-4'), 1), 0.1, function()self:on_finish() end)
    table.insert(self.parent, self)
end

function BloodFx:update(dt)
    self.animation:update(dt)
end

function BloodFx:on_finish()
    del(self.parent, self)
end

function BloodFx:draw()
    self.animation:draw(BLOOD_SPR, self.x, self.y, 0, 1, 1, 16, 16)
end
