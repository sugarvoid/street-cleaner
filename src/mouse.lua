Mouse = Object:extend()

local RETICLE_SHEET = love.graphics.newImage("asset/image/reticle_sheet.png")
local reticle_frames = {
    love.graphics.newQuad(0, 0, 26, 28, RETICLE_SHEET),
    love.graphics.newQuad(26, 0, 26, 28, RETICLE_SHEET),
    love.graphics.newQuad(52, 0, 26, 28, RETICLE_SHEET),
    love.graphics.newQuad(78, 0, 26, 28, RETICLE_SHEET),
    love.graphics.newQuad(104, 0, 26, 28, RETICLE_SHEET),
    love.graphics.newQuad(130, 0, 26, 28, RETICLE_SHEET),
    love.graphics.newQuad(156, 0, 26, 28, RETICLE_SHEET),
}

function Mouse:new()
    self.position = Position()
    self.hitbox = Hitbox(self, 0, 0, 8, 8, 13, 5)
    self.swayTimer = 0
    self.speed = 100
    self.focused = false
    self.frame = 1
    self.focus = 6
    self.__focus_tmr = 0
end

-- function Mouse:update(x, y)
--     --self.position.x = x - 16
--     --self.position.y = y - 6
--     self.hitbox:update()
-- end

function Mouse:update(dt)

    if input:down 'focus' and self.focus > 0 then
        self.__focus_tmr = 0
        self.focus = self.focus - 0.02
        self.speed = 200
    else
        self.speed = 100
        self.__focus_tmr = self.__focus_tmr + 1
        if self.__focus_tmr >= 60 and self.focus < 6 then
            self.focus = self.focus + 0.04
        end
    end

    -- if love.keyboard.isDown("x") and self.focus > 0 then
    --     self.__focus_tmr = 0
    --     self.focus = self.focus - 0.02
    --     self.speed = 200
    -- else
    --     self.speed = 100
    --     self.__focus_tmr = self.__focus_tmr + 1
    --     if self.__focus_tmr >= 60 and self.focus < 6 then
    --         self.focus = self.focus + 0.04
    --     end
    -- end

    self.frame = math.clamp(1, math.floor(self.focus + 1), 7)

    -- WASD movement
    -- if love.keyboard.isDown("up") then self.position.y = self.position.y - self.speed * dt end
    -- if love.keyboard.isDown("down") then self.position.y = self.position.y + self.speed * dt end
    -- if love.keyboard.isDown("left") then self.position.x = self.position.x - self.speed * dt end
    -- if love.keyboard.isDown("right") then self.position.x = self.position.x + self.speed * dt end

    if input:down 'left' then
        self.position.x = self.position.x - self.speed * dt
    end
    if input:down 'right' then
        self.position.x = self.position.x + self.speed * dt
    end
    if input:down 'up' then
        self.position.y = self.position.y - self.speed * dt
    end
    if input:down 'down' then
        self.position.y = self.position.y + self.speed * dt
    end

    -- sway timer for oscillation
    self.swayTimer = self.swayTimer + dt * 2
    if self.swayTimer >= 20 then
        self.swayTimer = 0
    end

    -- apply sway to position
    self.position.x = self.position.x + math.sin(self.swayTimer) * 0.3
    self.position.y = self.position.y + math.cos(self.swayTimer * 0.7) * 0.3

    self.hitbox:update()
end

function Mouse:draw()
    if is_debug_on then
        self.hitbox:draw()
    end
    love.graphics.draw(RETICLE_SHEET, reticle_frames[self.frame], self.position.x, self.position.y)
end
