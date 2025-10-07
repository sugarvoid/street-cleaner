ScoreFx = Object:extend()

local SCORE_SPR = love.graphics.newImage("asset/image/score_sheet.png")
local SCORE_GRID = anim8.newGrid(18, 18, SCORE_SPR:getWidth(), SCORE_SPR:getHeight())

local FRAMES = {
    -- one  = love.graphics.newQuad(0, 0, 18, 15, SCORE_SPR),
    -- two  = love.graphics.newQuad(18, 0, 18, 15, SCORE_SPR),
    -- five = love.graphics.newQuad(36, 0, 18, 15, SCORE_SPR),
    love.graphics.newQuad(0, 0, 18, 15, SCORE_SPR),
    love.graphics.newQuad(18, 0, 18, 15, SCORE_SPR),
    love.graphics.newQuad(36, 0, 18, 15, SCORE_SPR),
}

function ScoreFx:new(parent)
    self.position = Position()
    self.is_visible = true
    self.parent = parent
    --self.animation = anim8.newAnimation(SCORE_GRID(('1-4'), 1), 0.1, function() self:on_finish() end)
    --table.insert(self.parent, self)
end

function ScoreFx:update(dt)
    --self.animation:update(dt)
end

function ScoreFx:on_finish()
    del(self.parent, self)
end

function ScoreFx:draw()
    love.graphics.draw(SCORE_SPR, FRAMES[1], self.parent.position.x + 38, self.parent.position.y + 15, 0, 1, 1, 16, 16)
end
