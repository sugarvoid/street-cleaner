MuzzleFx = Object:extend()

local MUZZLE_SPR = love.graphics.newImage("asset/image/muzzle_flash_sheet.png")
local MUZZLE_GRID = anim8.newGrid(18, 18, MUZZLE_SPR:getWidth(), MUZZLE_SPR:getHeight())

function MuzzleFx:new(parent)
    self.x = x or 0
    self.y = y or 0
    self.position = Position()
    self.is_visible = false
    self.parent = parent
    self.animation = anim8.newAnimation(MUZZLE_GRID(('1-4'), 1), 0.1, function() self:on_finish() end)
    --table.insert(self.parent, self)
end

function MuzzleFx:update(dt)
    if self.is_visible then
        self.animation:update(dt)
    end
end

function MuzzleFx:show()
    self.animation:resume()
    self.animation:gotoFrame(1)
    self.is_visible = true
end

function MuzzleFx:on_finish()
    self.is_visible = false
    self.animation:pause()
end

function MuzzleFx:draw()
    if self.is_visible then
        self.animation:draw(MUZZLE_SPR, self.position.x, self.position.y, 0, 1, 1, 16, 16)
    end
end
