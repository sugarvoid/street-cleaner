is_debug_on = false



love = require("love")
Object = require "lib.classic"
logger = require("lib.log")
lume = require("lib.lume")
flux = require("lib.flux")
anim8 = require("lib.anim8")
batteries = require("lib.batteries")
Signal = require("lib.signal")

logger.info("Starting game")

math.randomseed(os.time())

if is_debug_on then
    love.profiler = require('lib.profile')
end

love.graphics.setDefaultFilter("nearest", "nearest")

local GAME_STATES = {
    title = 1,
    game = 2,
    pause = 3,
    gameover = 4,
}
local game_state = nil

local intro_time = 0
local high_score = 0
local level_length = 20

local show_flash = 0

all_clocks = {
    __clocks = {},
    update = function(self)
        for c in table.for_each(self.__clocks) do
            c:update()
        end
    end,
    add = function(self, c)
        table.insert(self.__clocks, c)
    end,
}

COLORS = {
    BLACK = "#000000",
    CF_BLUE = "#6495ED",
    WHITE = "#ffffff",
}


local pause_img = love.graphics.newImage("asset/image/pause.png")
local flash_img = love.graphics.newImage("asset/image/flash.png")

shake_duration = 0
shake_wait = 0
shake_offset = { x = 0, y = 0 }

require("src.clock")
require("src.enemy")
require("src.hitbox")
require("src.functions")
require("src.mouse")
require("lib.timer")
require("src.hud")

local screen_rect = { x = 0, y = 0, w = 384, h = 216 }
player = { ammo = 6, max_ammo = 6 }
mouse = Mouse()

tmr_ammo = Timer:new(60 * 2, function() add_ammo(1) end, true)

game_clock = Clock()
results_clock = Clock()
mx, my = 0, 0

all_clocks:add(tmr_ammo)
--all_clocks:add(results_clock)

local doorGuy = DoorGuy()
local windowGuy = WindowGuy()

enemies = {}

table.insert(enemies, doorGuy)
table.insert(enemies, windowGuy)

tmr_ammo:start()

function love.load()
    set_bgcolor_from_hex(COLORS.CF_BLUE)
    change_gamestate(GAME_STATES.title)
    high_score = load_high_score()
    if is_debug_on then
        logger.level = logger.Level.DEBUG
        logger.debug("Entering debug mode")
        love.profiler.start()
    else
        logger.level = logger.Level.DEBUG
        logger.info("logger in INFO mode")
    end

    font = love.graphics.newFont("asset/font/mago2.ttf", 32)
    font_hud = love.graphics.newFont("asset/font/mago2.ttf", 64)

    background_img = love.graphics.newImage("asset/image/streetCleanersLayout.png")

    font:setFilter("nearest")
    font_hud:setFilter("nearest")
    love.graphics.setFont(font)

    -- if your code was optimized for fullHD:
    window = { translateX = 0, translateY = 0, scale = 3, width = 384, height = 216 }
    width, height = love.graphics.getDimensions()
    love.window.setMode(width, height, { resizable = true, borderless = false })
    resize(width, height) -- update new translation and scale
end

function love.quit()
    logger.info("The game is closing.")
    if is_debug_on then
        love.profiler.stop()
        print(love.profiler.report(30))
    end
end

function love.update(dt)
    dt = math.min(dt, 1 / 60)

    if show_flash > 0 then
        show_flash = show_flash - 1
    end

    --doorGuy:update()

    for _, a in pairs(enemies) do
        --if a then
        a:update(dt)
        --end
    end

    mx = math.floor((love.mouse.getX() - window.translateX) / window.scale + 0.5)
    my = math.floor((love.mouse.getY() - window.translateY) / window.scale + 0.5)

    all_clocks:update()
    --game_clock:update()

    if game_state == GAME_STATES.game then
        if shake_duration > 0 then
            shake_duration = shake_duration - dt
            if shake_wait > 0 then
                shake_wait = shake_wait - dt
            else
                shake_offset.x = love.math.random(-5, 5)
                shake_offset.y = love.math.random(-5, 5)
                shake_wait = 0.02
            end
        end
        update_game(dt)
    end

    if game_state == GAME_STATES.pause then
        update_pause()
    end

    -- if gamestate == GAMESTATES.day_intro then
    --     update_day_intro()
    -- end

    if game_state == GAME_STATES.day_title then
        update_day_title()
    end

    --print((collectgarbage('count') / 1024))
    mouse:update(mx, my)
end

function love.mousepressed(x, y, button, _)
    --mx = math.floor((x - window.translateX) / window.scale + 0.5)
    --my = math.floor((y - window.translateY) / window.scale + 0.5)

    shoot()



    --print("click on " .. mx .. " " .. my)
end

function shoot()
    if player.ammo >= 1 then
        player.ammo = math.clamp(0, player.ammo - 1, player.max_ammo)
        show_flash = 0
        show_flash = 2

        for _, e in pairs(enemies) do
            --if a then
            e:check_if_hovered()
            --end
        end
    else
        --TODO: Play empty sound
    end

    -- body
end

function love.keypressed(key, scancode, isrepeat)
    if key == "tab" then
        local state = not love.mouse.isVisible() -- the opposite of whatever it currently is
        love.mouse.setVisible(state)
    end

    if not isrepeat then
        if key == "escape" then
            quit_game()
        end

        if key == "r" then
            love.event.push("quit", "restart")
        end

        if game_state == GAME_STATES.title then
        elseif game_state == GAME_STATES.game then
            if key == "space" then
                game_state = GAME_STATES.pause
                is_paused = true
                return
            end
        elseif game_state == GAME_STATES.pause then
            if key == "space" then
                print("on pause pressing pause")
                game_state = GAME_STATES.game
                is_paused = false
                return
            end
        elseif game_state == GAME_STATES.gameover then

        end
    end
end

function setup_residents()
    for _ = 1, customer_count do
        table.insert(residents, true)
    end
    for _ = 1, noncustomer_count do
        table.insert(residents, false)
    end
    residents = batteries.tablex.shuffle(residents)
    batteries.tablex.push(residents, {}) --HACK: Hacky way to handle spawning all mailboxes.
end

function change_gamestate(state)
    if state == GAME_STATES.game then
    end
    game_state = state
end

function love.draw()
    -- first translate, then scale
    love.graphics.translate(window.translateX, window.translateY)
    if shake_duration > 0 then
        love.graphics.translate(shake_offset.x, shake_offset.y)
    end
    love.graphics.scale(window.scale)
    -- your graphics code here, optimized for fullHD

    love.graphics.draw(background_img, 0, 0)

    for _, a in pairs(enemies) do
        --if a then
        a:draw()
        --end
    end

    mouse:draw()

    if game_state == GAME_STATES.title then
        draw_title()
    end

    if game_state == GAME_STATES.game then
        draw_game()
    end

    if game_state == GAME_STATES.gameover then
        draw_gameover()
    end

    if show_flash > 0 then
        love.graphics.draw(flash_img, 0, 0)
    end

    love.graphics.push("all")
    set_color_from_hex(COLORS.BLACK)
    love.graphics.rectangle("fill", 0, 180, 384, 40)
    love.graphics.pop()

    hud:draw()

    if game_state == GAME_STATES.pause then
        draw_game()
        draw_pause()
    end

    --print("Current FPS: "..tostring(love.timer.getFPS( )))
    --print('Memory used: ' .. string.format("%.2f", collectgarbage('count')/1000) .. " MB")
end

function resize(w, h)
    --[[]
    update new translation and scale:
    target rendering resolution
    ]]
    --                  --
    local _w1, _h1 = window.width, window.height
    local _scale = math.min(w / _w1, h / _h1)
    window.translateX, window.translateY, window.scale = (w - _w1 * _scale) / 2, (h - _h1 * _scale) / 2, _scale
end

function love.resize(w, h)
    resize(w, h) -- update new translation and scale
end

function quit_game()
    love.event.quit()
end

function table.remove_item(tbl, item)
    for i, v in ipairs(tbl) do
        if v == item then
            tbl[i] = tbl[#tbl]
            tbl[#tbl] = nil
            return
        end
    end
end

function goto_gameover(reason)
    shake_duration = 0
    game_clock:restart()
    spawner:reset()
    results_clock:restart()
    save_high_score(player.score)
    bg_music:stop()
    change_gamestate(GAME_STATES.gameover)

    print("game over: " .. reason)
end

function draw_title()

end

function draw_day_title()

end

function draw_game()
    for s in table.for_each(bones) do
        s:draw()
    end
end

function draw_pause()
    love.graphics.draw(pause_img, -50, 0)
end

function draw_gameover()
    love.graphics.draw(gameover_paper, 0, 0)
    love.graphics.push("all")
    set_color_from_hex(COLORS.BLACK)
    love.graphics.print("Game Over", 37, 8, 0, 0.6, 0.6)
    love.graphics.pop()
end

function is_on_screen(obj)
    if ((obj.x >= screen_rect.x + screen_rect.w) or
            (obj.x + obj.w <= screen_rect.x) or
            (obj.y >= screen_rect.y + screen_rect.h) or
            (obj.y + obj.h <= screen_rect.y)) then
        return false
    else
        return true
    end
end

function start_game()
    game_clock:start()
    spawner:start()
    high_score = load_high_score()
    change_gamestate(GAME_STATES.game)
    bg_music:setVolume(0.2)
    bg_music:play()
    spawner:reset()
    shake_duration = 0
    shake_wait = 0
    shake_offset = { x = 0, y = 0 }
end

function reset_game()
    player_score = 0
    change_gamestate(GAME_STATES.title)
end

function update_game(dt)
    flux.update(dt)

    for s in table.for_each(bones) do
        s:update(dt)
    end
end

function update_pause()

end

function show_info()
    change_gamestate(GAME_STATES.info)
    --gamestate = gamestates.info
end

function save_high_score(score)
    if score > high_score then
        local file = love.filesystem.newFile("data.sav")
        file:open("w")
        file:write(score)
        file:close()
    end
end

function load_high_score()
    local score, _ = love.filesystem.read("data.sav")
    score = tonumber(score)
    return score or 0
end

function add_ammo(n)
    player.ammo = math.clamp(0, player.ammo + n, player.max_ammo)
end
