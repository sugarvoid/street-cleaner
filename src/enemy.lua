BaseEnemy = Object:extend()

local DOOR_SPR = love.graphics.newImage("asset/image/door_sheet.png")
local DOOR_GRID = anim8.newGrid(26, 42, DOOR_SPR:getWidth(), DOOR_SPR:getHeight())

local WINDOW_SPR = love.graphics.newImage("asset/image/window_guy.png")
local WINDOW_GRID = anim8.newGrid(24, 24, WINDOW_SPR:getWidth(), WINDOW_SPR:getHeight())

local RUNNER_SPR = love.graphics.newImage("asset/image/runner_sheet.png")
local RUNNER_GRID = anim8.newGrid(42, 42, RUNNER_SPR:getWidth(), RUNNER_SPR:getHeight())

local JUMPER_SPR = love.graphics.newImage("asset/image/jumper_sheet.png")
local JUMPER_GRID = anim8.newGrid(24, 40, JUMPER_SPR:getWidth(), JUMPER_SPR:getHeight())

-- function anim_done(s)
--     print(s .. " animation is done")
-- end


SPAWN_DATA = {
    { index = 1, id = "d1", available = true, position = { x = 115, y = 80 } },
    { index = 2, id = "d2", available = true, position = { x = 325, y = 65 } },

    { index = 3, id = "w1", available = true, position = { x = 21, y = 25 } },
    { index = 4, id = "w2", available = true, position = { x = 69, y = 25 } },
    { index = 5, id = "w3", available = true, position = { x = 117, y = 25 } },
    { index = 6, id = "w4", available = true, position = { x = 276, y = 8 } },
    { index = 7, id = "w5", available = true, position = { x = 325, y = 8 } },
    { index = 8, id = "w6", available = true, position = { x = 276, y = 60 } },

}



DOOR_SPAWN_POS = {
    { id = "d1", available = true, position = { x = 115, y = 80 } },
    { id = "d2", available = true, position = { x = 325, y = 65 } },
}

WINDOW_SPAWN_POS = {
    { id = "w1", available = true, position = { x = 21, y = 25 } },
    { id = "w2", available = true, position = { x = 69, y = 25 } },
    { id = "w3", available = true, position = { x = 117, y = 25 } },

    { id = "w4", available = true, position = { x = 276, y = 8 } },
    { id = "w5", available = true, position = { x = 325, y = 8 } },
    { id = "w6", available = true, position = { x = 276, y = 60 } },
}

RUNNER_SPAWN_POS = {

}

function BaseEnemy:new()
    self.location = nil
    self.is_alive = true
    self.position = { x = 0, y = 0 }
    self.hitbox = {}
    self.spr_sheet = nil
    --self.moving_dir = { 0, 0 }
    self.speed = nil
    self.current_anim = nil
    self.shoot_cooldown = get_rnd(60 * 2, 60 * 5)
    self.tmr_shoot = Timer:new(self.shoot_cooldown, function() self:shoot() end, true)
    self.animations = { enter = {}, die = nil, jump = nil, land = nil, run = nil }
    self.is_hovered = false
    self.location_index = nil
end

function BaseEnemy:draw()
    self.current_anim:draw(self.spr_sheet, self.position.x, self.position.y)
    self.hitbox:draw()
end

function BaseEnemy:check_if_hovered()
    if is_colliding(mouse.hitbox, self.hitbox) and self.is_alive then
        print(self.id .. " been shot")
        self:on_hit()
    end
end

function BaseEnemy:shoot()
    if self.is_alive then
        print("shooting")
        self.tmr_shoot:stop()
        player:take_damage()
        self.shoot_cooldown = get_rnd(60 * 3, 60 * 5)
        self.tmr_shoot:start()
    end
end

function BaseEnemy:on_hit()
    print(self)
    BloodFx(mx, my, blood_container)
    self.is_alive = false
    self.current_anim = self.animations.die
    self.current_anim:resume()
end

function BaseEnemy:update(dt)
    self.is_hovered = is_colliding(mouse.hitbox, self.hitbox) and self.is_alive
    self.tmr_shoot:update()
    self.hitbox:update()
    self.current_anim:update(dt)
    if self.name == "runner" then
        self.position.x = self.position.x + self.speed * dt
    end
    if self.speed then
        --TODO: this is for runner to move across the screen
    end
end

function BaseEnemy:remove()
    if self.location_index then
        SPAWN_DATA[self.location_index].available = true
    end
    del(enemies, self)
end

DoorGuy = BaseEnemy:extend()

function DoorGuy:new(idx)
    DoorGuy.super.new(self)
    self.id = "door_01"

    local _spawn = get_random_item(DOOR_SPAWN_POS).position
    --self.position = { x = _spawn.x, y = _spawn.y }

    local s_data = SPAWN_DATA[idx]
    self.location_index = idx
    self.position = { x = s_data.position.x, y = s_data.position.y }


    self.spr_sheet = DOOR_SPR
    self.hitbox = Hitbox(self, 0, 0, 20, 42, 2)

    self.animations.enter = anim8.newAnimation(DOOR_GRID(('1-3'), 1), 0.2, function() self:anim_done("enter") end)
    self.animations.die = anim8.newAnimation(DOOR_GRID(('4-6'), 1), 0.2, function() self:anim_done("die") end)

    for _, a in pairs(self.animations) do
        if a then
            a:flipH()
        end
    end

    self.current_anim = self.animations.enter
end

function DoorGuy:anim_done(s)
    if s == "enter" then
        self.tmr_shoot:start()
        self.current_anim:gotoFrame(3)
        self.current_anim:pause()
    elseif s == "die" then
        print("dying done")
        self.current_anim:gotoFrame(3)
        self.current_anim:pause()
        self:remove()
    end
end

WindowGuy = BaseEnemy:extend()

function WindowGuy:new(idx)
    WindowGuy.super.new(self)
    self.id = "door_01"

    -- self.position = get_random_item(WINDOW_SPAWN_POS).position

    local s_data = SPAWN_DATA[idx]

    self.location_index = idx
    local _spawn = get_random_item(WINDOW_SPAWN_POS).position
    --self.position = { x = _spawn.x, y = _spawn.y }
    self.position = { x = s_data.position.x, y = s_data.position.y }
    self.spr_sheet = WINDOW_SPR
    self.hitbox = Hitbox(self, 0, 0, 20, 24, 2)

    self.animations.enter = anim8.newAnimation(WINDOW_GRID(('1-3'), 1), 0.2, function() self:anim_done("enter") end)
    self.animations.die = anim8.newAnimation(WINDOW_GRID(('4-6'), 1), 0.2, function() self:anim_done("die") end)

    if math.random(0, 1) == 0 then
        for _, a in pairs(self.animations) do
            if a then
                a:flipH()
            end
        end
    end

    self.current_anim = self.animations.enter
end

function WindowGuy:anim_done(s)
    if s == "enter" then
        self.tmr_shoot:start()
        self.current_anim:gotoFrame(3)
        self.current_anim:pause()
    elseif s == "die" then
        print("dying done")
        self.current_anim:gotoFrame(3)
        self.current_anim:pause()
        self:remove()
    end
end

RunnerGuy = BaseEnemy:extend()

function RunnerGuy:new()
    RunnerGuy.super.new(self)
    self.id = "door_01"
    self.name = "runner"
    self.speed = -25
    --TODO: Make positions random-ish
    self.position = { x = 150, y = 100 }
    self.spr_sheet = RUNNER_SPR
    self.hitbox = Hitbox(self, 0, 0, 16, 38, 16, 3)

    self.animations.enter = anim8.newAnimation(RUNNER_GRID(('1-2'), 1), 0.2, function() self:anim_done("enter") end)
    self.animations.die = anim8.newAnimation(RUNNER_GRID(('3-4'), 1), 0.2, function() self:anim_done("die") end)

    if math.random(0, 1) == 0 then
        self.speed = self.speed * -1
        for _, a in pairs(self.animations) do
            if a then
                a:flipH()
            end
        end
    end

    self.current_anim = self.animations.enter
end

function RunnerGuy:anim_done(s)
    if s == "enter" then

    elseif s == "die" then
        print("dying done")
        self.speed = 0
        self.current_anim:gotoFrame(3)
        self.current_anim:pause()
        self:remove()
    end
end

JumperGuy = BaseEnemy:extend()

function JumperGuy:new()
    JumperGuy.super.new(self)
    self.id = "door_01"
    self.name = "jumper"
    self.speed = -25

    --TODO: Make a better function that all enemey types can use (DRY)
    local _spawn = get_random_item(WINDOW_SPAWN_POS).position
    self.position = { x = _spawn.x, y = _spawn.y }
    self.starting_y = self.position.y
    self.peak_y = self.starting_y - 10
    self.landing_y = 110
    self.spr_sheet = JUMPER_SPR
    self.hitbox = Hitbox(self, 0, 0, 20, 32, 4, 3)

    self.animations.enter = anim8.newAnimation(JUMPER_GRID(('1-3'), 1), 1, function() self:anim_done("enter") end)
    self.animations.die = anim8.newAnimation(JUMPER_GRID(('4-6'), 1), 0.2, function() self:anim_done("die") end)

    if math.random(0, 1) == 0 then
        self.speed = self.speed * -1
        for _, a in pairs(self.animations) do
            if a then
                a:flipH()
            end
        end
    end

    self.current_anim = self.animations.enter

    self.current_anim:pause()
    self.current_anim:gotoFrame(2)

    flux.to(self.position, 0.1, { y = self.peak_y }):oncomplete(
        function()
            self.current_anim:gotoFrame(3)
        end):after(self.position, 0.4, { y = self.landing_y }):oncomplete(
        function()
            self.current_anim:gotoFrame(1)
            self.tmr_shoot:start()
        end)
end

function JumperGuy:anim_done(s)
    if s == "enter" then

    elseif s == "die" then
        print("dying done")
        self.speed = 0
        self.current_anim:gotoFrame(3)
        self.current_anim:pause()
        self:remove()
    end
end
