
BaseEnemy = Object:extend()

local DOOR_SPR = love.graphics.newImage("asset/image/door_sheet.png")
local DOOR_GRID = anim8.newGrid(26, 42, DOOR_SPR:getWidth(), DOOR_SPR:getHeight())

--local WINDOW_SPR = love.graphics.newImage("asset/image/baddie_1.png")
--local RUNNER_SPR = love.graphics.newImage("asset/image/baddie_2.png")

all_ships = {}

function BaseEnemy:new()
    self.position = {x = 0, y = 0}
    self.sprite = nil
    self.scale = 1
    self.moving_dir = {0, 0}
    self.speed = nil
    self.distance = 2
    self.animations = {enter = nil, die = nil, jump = nil, land = nil, run = nil}
end

function BaseEnemy:draw()
    love.graphics.draw(self.sprite, self.position.x, self.position.y, 0, self.scale, self.scale)
end

function BaseEnemy:onHit()
end

function BaseEnemy:update()
    --logger.fatal("Enemy class does not have update function.")
    error("Enemy needs their own update function.")
end

DoorGuy = BaseEnemy:extend()

--love.graphics.line(227 / 2 - 20, 30, 227 / 2 - 40, 128)

function DoorGuy:new()
    Mothership.super.new(self)
    self.position.x = 30
    self.position.y = 20
    self.sprite = MOTHERSHIP_SPR
    self.scale = .7
    self.speed = 20
    self.move_dir = 1
    print(self.position)
end

function DoorGuy:update(dt)
    self.position.x = self.position.x + (self.speed * self.move_dir) * dt
    logger.info(self.position.x)
end

--MovingShip = BaseEnemy:extend()

GreenShip = BaseEnemy:extend()
WhiteShip = BaseEnemy:extend()

function MovingShip:new(kind)
    MovingShip.super.new(self)
    if kind == "green" then
        self.sprite = GREEN_SHIP_SPR
    elseif kind == "white" then
        self.sprite = WHITE_SHIP_SPR
    end
    self.scale = nil
    self.lane = 5
end

function MovingShip:change_lane(dir)
    self.lane = self.lane + dir
end

function MovingShip:update(dt)
    self.position = get_point_along_line(self.lane, self.distance)
    self.scale = (self.distance * .01) + .25
end

function MovingShip:draw()
    love.graphics.draw(self.sprite, self.position.x, self.position.y, 0, self.scale, self.scale, 8, 8)
end

function get_line_point(start_pos, end_pos, dist)
    local u = {end_pos.x - start_pos.x, end_pos.y - start_pos.y}
    local p = 0
end
