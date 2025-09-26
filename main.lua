is_debug_on = false

love = require("love")
Object = require "lib.classic"
logger = require("lib.log")
lume = require("lib.lume")
flux = require("lib.flux")
anim8 = require("lib.anim8")
batteries = require("lib.batteries")
Signal = require("lib.signal")

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
    BLACK       = "#000000",
    BROWN       = "#733e39",
    DARK_GRAY   = "#5a6988",
    WHITE       = "#ffffff",
    LIGHT_BROWN = "#ead4aa",
    CF_BLUE     = "#6495ED",
}

--TODO: Replace places wher I used COLORS
PALETTE = {
    BRICK_RED    = "#be4a2f",
    BURNT_ORANGE = "#d77643",
    PALE_BEIGE   = "#ead4aa",
    PEACH        = "#e4a672",
    BROWN        = "#b86f50",
    DARK_BROWN   = "#733e39",
    DEEP_PLUM    = "#3e2731",
    CRIMSON      = "#a22633",
    RED          = "#e43b44",
    ORANGE       = "#f77622",
    GOLDENROD    = "#feae34",
    LEMON        = "#fee761",
    LIME_GREEN   = "#63c74d",
    GREEN        = "#3e8948",
    FOREST_GREEN = "#265c42",
    TEAL         = "#193c3e",
    ROYAL_BLUE   = "#124e89",
    SKY_BLUE     = "#0099db",

    WHITE        = "#ffffff",
    LIGHT_GRAY   = "#c0cbdc",
    GRAY_BLUE    = "#8b9bb4",
    SLATE        = "#5a6988",
    NAVY_BLUE    = "#3a4466",
    DARK_NAVY    = "#262b44",
    NEAR_BLACK   = "#181425",
    HOT_PINK     = "#ff0044",
    PURPLE_GRAY  = "#68386c",
    MAUVE        = "#b55088",
    PINK         = "#f6757a",
    TAN          = "#e8b796",
    TAUPE        = "#c28569"
}


local pause_img = love.graphics.newImage("asset/image/pause.png")

shake_duration = 0
shake_wait = 0
shake_offset = { x = 0, y = 0 }

require("src.clock")
require("src.hitbox")
require("src.functions")
require("lib.timer")


local screen_rect = { x = 0, y = 0, w = 384, h = 216 }
player = nil
game_clock = Clock()
results_clock = Clock()

all_clocks:add(game_clock)
all_clocks:add(results_clock)

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
    math.randomseed(os.time())
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
end

function love.mousepressed(x, y, button, _)
    mx = math.floor((x - window.translateX) / window.scale + 0.5)
    my = math.floor((y - window.translateY) / window.scale + 0.5)

    print("click on " .. mx .. " " .. my)
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

    if game_state == GAME_STATES.title then
        draw_title()
    end

    if game_state == GAME_STATES.game then
        draw_game()
    end

    if game_state == GAME_STATES.gameover then
        draw_gameover()
    end

    love.graphics.push("all")
    set_color_from_hex(COLORS.BLACK)
    love.graphics.rectangle("fill", 0, 180, 384, 40)
    love.graphics.pop()

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

function table.for_each(list)
    local _i = 0
    return function()
        _i = _i + 1; return list[_i]
    end
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
    show_results = false
    results_clock:restart()
    save_high_score(player.score)
    bg_music:stop()
    if reason == "mailbox" then
        gameover_img = gameover_imgs.fired
        gameover_txt = "Mailman fired!"
        gameover_sub_txt = "Too many crashes"
    elseif reason == "missed" then
        gameover_img = gameover_imgs.fired
        gameover_txt = "Mailman fired!"
        gameover_sub_txt = ""
    elseif reason == "fell" then
        gameover_img = gameover_imgs.hole
        gameover_txt = "Mailman missing!"
        gameover_sub_txt = ""
    elseif reason == "too_high" then
        gameover_img = gameover_imgs.sky
        gameover_txt = "Mailman missing!"
        gameover_sub_txt = ""
    end
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
    draw_mailboxes()
    for l in table.for_each(all_letters) do
        l:draw()
    end
    for d in table.for_each(twisters) do
        d:draw()
    end

    for so in table.for_each(sfx_objects) do
        so:draw()
    end

    for r in table.for_each(rocks) do
        r:draw()
    end
    spawner:draw_hazards()

    draw_walls()
    draw_particles()

    player:draw()

    if show_results then
        draw_results()
    end
end

function draw_results()
    --TODO: Change to show customers and stuff
    love.graphics.push("all")
    set_color_from_hex(COLORS.WHITE)
    love.graphics.print("delivered", 20, 20, 0, 0.5, 0.5)
    love.graphics.print(player.deliveries, 78, 20, 0, 0.5, 0.5)
    love.graphics.print("customers", 20, 36, 0, 0.5, 0.5)
    love.graphics.print(customer_count, 78, 36, 0, 0.5, 0.5)
    --love.graphics.print("new customers", 20, 36 + 16, 0, 0.5, 0.5)
    --love.graphics.print(new_customers, 78, 36 + 16, 0, 0.5, 0.5)
    --love.graphics.line(15, 50 + 18, 25 + 70, 50 + 18)
    --love.graphics.print("earned", 20, 60 + 8, 0, 0.5, 0.5)
    --love.graphics.print(0, 78, 60 + 8, 0, 0.5, 0.5)
    love.graphics.pop()
end

function draw_pause()
    love.graphics.draw(pause_img, -50, 0)
    love.graphics.print("_", 49, 40 + (pause_index * 8))
    love.graphics.print("Resume", 57, 50, 0, 0.5, 0.5)
    love.graphics.print("quit", 57, 66, 0, 0.5, 0.5)
end

function draw_gameover()
    love.graphics.draw(gameover_paper, 0, 0)
    love.graphics.push("all")
    set_color_from_hex(COLORS.BLACK)
    love.graphics.print("Game Over", 37, 8, 0, 0.6, 0.6)
    -- TODO: Figure out best location for text
    love.graphics.print(gameover_txt, 12, 30, 0, 0.4, 0.4)
    love.graphics.print(gameover_sub_txt, 12, 40, 0, 0.3, 0.3)
    love.graphics.pop()
    love.graphics.draw(gameover_img, 68, 34)
end

function draw_info()
    love.graphics.push("all")
    set_color_from_hex(COLORS.BLACK)
    love.graphics.rectangle("fill", 0, 0, 128, 128)
    love.graphics.pop()

    love.graphics.push("all")
    set_color_from_hex(COLORS.BLUE)
    love.graphics.print("Customers", 42, 20, 0, 0.5, 0.5)
    love.graphics.print("Bule", 42, 28, 0, 0.5, 0.5)
    love.graphics.pop()

    love.graphics.push("all")
    set_color_from_hex(COLORS.LIGHT_GRAY)
    love.graphics.print("Non-Customers", 42, 50, 0, 0.5, 0.5)
    love.graphics.print("Gray", 42, 58, 0, 0.5, 0.5)
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

function is_colliding(rect_a, rect_b)
    if ((rect_a.x >= rect_b.x + rect_b.w) or
            (rect_a.x + rect_a.w <= rect_b.x) or
            (rect_a.y >= rect_b.y + rect_b.h) or
            (rect_a.y + rect_a.h <= rect_b.y)) then
        return false
    else
        return true
    end
end

function start_game()
    init_wind()

    -- TODO: fix player score getting reset after each day
    --reset_game()
    game_clock:start()
    spawner:start()
    high_score = load_high_score()
    change_gamestate(GAME_STATES.game)
    bg_music:setVolume(0.2)
    bg_music:play()
    player:reset()
    spawner:reset()
    shake_duration = 0
    shake_wait = 0
    shake_offset = { x = 0, y = 0 }
    hud:reset()
end

function reset_game()
    player.score = 0
    change_gamestate(GAME_STATES.title)
    setup_residents()
    current_day = 1
end

function update_day_title()
    day_time = day_time - 1

    if day_time <= 0 then
        start_game()
        return
    end
end

function update_game(dt)
    flux.update(dt)
    update_particles()
    hud:update()
    update_walls()
    --results_clock:update()

    if mailbox_num == #residents then
        --if game_clock.seconds >= level_length then
        game_clock:stop()
        spawner:stop()

        if spawner.get_object_count() == 0 then
            game_clock:restart()
            bg_music:setVolume(0.1)
            spawner:reset()
            results_clock:start()
            --TODO: If all deliveries made, turn one red mailbox to blue
            if player.deliveries == customer_count then
                new_customers = 1
                resubscribe()
            end
            show_results = true
        end
    end

    if results_clock.seconds >= 5 and results_clock.is_running then
        results_clock:stop()
        show_results = false
        results_clock:restart()

        advance_day()
    end

    --if #twisters == 3 and not wormhole_active then
    --spawn_wormhole(player.x, player.y)
    --wormhole_active = true
    --end
    -- for _, t in ipairs(timers) do
    --     t:update()
    -- end

    player:update(dt)
    --update_things(dt)
    update_windlines(dt)

    spawner:update(dt)

    for s in table.for_each(bones) do
        s:update(dt)
    end
    update_mailboxes(dt)
    for l in table.for_each(all_letters) do
        l:update(dt)
    end
    for d in table.for_each(twisters) do
        d:update(dt)
    end
    for so in table.for_each(sfx_objects) do
        so:update(dt)
    end
    --for _, b in ipairs(back_objects) do
    --  b:update(dt)
    --end
    for r in table.for_each(rocks) do
        r:update(dt)
    end
end

function update_pause()

end

function show_info()
    change_gamestate(GAME_STATES.info)
    --gamestate = gamestates.info
end

function advance_day()
    logger.debug("residents table has: " .. #residents)
    customer_count = 0
    for r in table.for_each(residents) do
        if r == true then
            customer_count = customer_count + 1
        end
    end
    current_day = current_day + 1
    if current_day == 8 then
        current_day = 1
    end
    change_gamestate(GAME_STATES.day_title)
    mailbox_num = 1
    player:reset()
end

function table.for_each(_list)
    local i = 0
    return function()
        i = i + 1; return _list[i]
    end
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
