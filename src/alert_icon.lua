AlertFx = Object:extend()

local ALERT_SPR = love.graphics.newImage("asset/image/alert_icon_sheet.png")
local ALERT_GRID = anim8.newGrid(8, 16, ALERT_SPR:getWidth(), ALERT_SPR:getHeight())

function AlertFx:new(parent, x, y)
    self.x = x or 0
    self.y = y or 0
    self.is_visible = false
    self.parent = parent
    self.animation = anim8.newAnimation(ALERT_GRID(('1-6'), 1), 0.06, function() self:on_finish() end)
    --table.insert(self.parent, self)
end

function AlertFx:update(dt)
    if self.is_visible then
        self.animation:update(dt)
    end
end

function AlertFx:show()
    self.animation:resume()
    self.animation:gotoFrame(1)
    self.is_visible = true
end

function AlertFx:on_finish()
    self.is_visible = false
    self.animation:pause()
    self.parent:shoot()
end

function AlertFx:draw()
    if self.is_visible then
        self.animation:draw(ALERT_SPR, self.x, self.y, 0, 1, 1, 16, 16)
    end
end
