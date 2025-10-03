AlertFx = Object:extend()

local ALERT_SPR = love.graphics.newImage("asset/image/alert_icon_sheet.png")
local ALERT_GRID = anim8.newGrid(8, 16, ALERT_SPR:getWidth(), ALERT_SPR:getHeight())

function AlertFx:new(parent)
    self.position = Position()
    --self.x = x or 0
    --self.y = y or 0
    self.is_visible = false
    self.parent = parent
    self.animation = anim8.newAnimation(ALERT_GRID(('1-6'), 1), 0.1, function() self:on_finish() end)
    --table.insert(self.parent, self)
end

function AlertFx:update(dt)
    if self.is_visible then
            --self.position.x = self.parent.alert_pos.x
            --self.position.y = self.parent.alert_pos.y - 1
        self.animation:update(dt)
    end
end

function AlertFx:show()
    self.is_visible = true
    self.animation:resume()
    self.animation:gotoFrame(1)
    
end

function AlertFx:on_finish()
    self.is_visible = false
    self.animation:pause()
    self.parent:shoot()
end

function AlertFx:draw()
    if self.is_visible then
        self.animation:draw(ALERT_SPR, self.position.x, self.position.y, 0, 1, 1)
    end
end
