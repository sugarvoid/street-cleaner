
PlayerHit = Object:extend()

local BULLET_HIT = love.graphics.newImage("asset/image/screen_bullet_hole.png")

function PlayerHit:new(container)
    self.x = get_rnd(30, 350)
    self.y = get_rnd(30, 180)
    self.tic = 0
    self.parent = container
    table.insert(self.parent, self)
end

function PlayerHit:update(dt)
    self.tic = self.tic + 1
    if self.tic >= 120 then
        del(self.parent, self)
    end
end

function PlayerHit:draw()
    love.graphics.draw(BULLET_HIT, self.x, self.y, 0, 1, 1, 20, 16)
end
