
BaseEnemy = Object:extend()

local DOOR_SPR = love.graphics.newImage("asset/image/door_sheet.png")
local DOOR_GRID = anim8.newGrid(26, 42, DOOR_SPR:getWidth(), DOOR_SPR:getHeight())

--local WINDOW_SPR = love.graphics.newImage("asset/image/baddie_1.png")
--local RUNNER_SPR = love.graphics.newImage("asset/image/baddie_2.png")

function anim_done(s)
    print(s .. " animation is done")
end

DOOR_SPAWN_POS = {
    {x=115, y=80},
    {x=325, y=65},
}

WINDOW_SPAWN_POS = {

    {33-12,37-12},
    {81-12,37-12},
    {129-12,37-12},
    {288-12,20-12},
    {337-12,20-12},
    {228-12,72-12},
}



all_ships = {}

function BaseEnemy:new()
    self.position = {x = 0, y = 0}
    self.sprite = nil
    self.scale = 1
    self.hitbox = {}
    self.spr_sheet = nil
    self.moving_dir = {0, 0}
    self.speed = nil
    self.distance = 2
    self.current_anim = nil
    self.animations = {enter = {}, die = nil, jump = nil, land = nil, run = nil}
end

function BaseEnemy:draw()
    --love.graphics.draw(self.sprite, self.position.x, self.position.y, 0, self.scale, self.scale)
    self.current_anim:draw(self.spr_sheet, self.position.x, self.position.y)
    self.hitbox:draw()
end

function BaseEnemy:check_if_hovered()
    if is_colliding(mouse.hitbox, self.hitbox) then
        print(self.id .. " been shot")
        self:on_hit()
    end
end

function BaseEnemy:on_hit()
    self.current_anim = self.animations.die
    self.current_anim:resume()
end

function BaseEnemy:update()
    --logger.fatal("Enemy class does not have update function.")
    error("Enemy needs their own update function.")
end

DoorGuy = BaseEnemy:extend()

--love.graphics.line(227 / 2 - 20, 30, 227 / 2 - 40, 128)

function DoorGuy:new()
    DoorGuy.super.new(self)
    self.id = "door_01"
    self.position = get_random_item(DOOR_SPAWN_POS)
    self.spr_sheet = DOOR_SPR
    self.hitbox = Hitbox(self, 0, 0, 25, 42)

    self.animations.enter = anim8.newAnimation(DOOR_GRID(('1-3'), 1), 0.2, function()self:anim_done("enter") end)
    self.animations.die = anim8.newAnimation(DOOR_GRID(('4-6'), 1), 0.2, function()self:anim_done("die") end)
    --self.animations.enter:pauseAtEnd()

    for _, a in pairs(self.animations) do
        if a then
           a:flipH()
        end
    end


    self.current_anim = self.animations.enter
    
    --self.current_anim:flipH()
end

function DoorGuy:update(dt)
    self.hitbox:update()
    self.current_anim:update(dt)
    --self.position.x = self.position.x + (self.speed * self.move_dir) * dt
end

function DoorGuy:anim_done(s)
    if s == "enter" then
        self.current_anim:gotoFrame(3)
        self.current_anim:pause()
    elseif s == "die" then
        print("dying done")
        self.current_anim:gotoFrame(3)
        self.current_anim:pause()
    end
end

--MovingShip = BaseEnemy:extend()

GreenShip = BaseEnemy:extend()
WhiteShip = BaseEnemy:extend()

-- function MovingShip:new(kind)
--     MovingShip.super.new(self)
--     if kind == "green" then
--         self.sprite = GREEN_SHIP_SPR
--     elseif kind == "white" then
--         self.sprite = WHITE_SHIP_SPR
--     end
--     self.scale = nil
--     self.lane = 5
-- end

-- function MovingShip:change_lane(dir)
--     self.lane = self.lane + dir
-- end

-- function MovingShip:update(dt)
--     self.position = get_point_along_line(self.lane, self.distance)
--     self.scale = (self.distance * .01) + .25
-- end

-- function MovingShip:draw()
--     love.graphics.draw(self.sprite, self.position.x, self.position.y, 0, self.scale, self.scale, 8, 8)
-- end

function get_line_point(start_pos, end_pos, dist)
    local u = {end_pos.x - start_pos.x, end_pos.y - start_pos.y}
    local p = 0
end
