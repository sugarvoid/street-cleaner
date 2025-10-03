is_debug_on = false

--love = require("love")
Object = require "lib.classic"
logger = require("lib.log")
flux = require("lib.flux")
anim8 = require("lib.anim8")

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


local shoot_player = love.audio.newSource("asset/shoot_player.ogg", "static")
shoot_player:setVolume(0.4)

local bg_music = love.audio.newSource("asset/c_muPlumusLand.ogg", "stream")
bg_music:setLooping(true)

show_hurt = 0

all_clocks = {
    __clocks = {},
    update = function(self)
        -- for c in table.for_each(self.__clocks) do
        --     c:update()
        -- end

        for _, c in ipairs(self.__clocks) do
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
local hurt_img = love.graphics.newImage("asset/image/player_hit.png")
local wall = love.graphics.newImage("asset/image/wall.png")

enemies = {}
blood_container = {}
bhit_container = {}

require("src.functions")
require("src.clock")
require("src.alert_icon")
require("src.score_fx")
require("src.muzzle_flash")
require("src.enemy")
require("src.hitbox")

require("src.mouse")
require("lib.timer")
require("src.hud")
require("src.blood_fx")
require("src.player_hit_fx")
require("src.spawner")
require("src.player")

local screen_rect = {x = 0, y = 0, w = 384, h = 216}

mouse = Mouse()
spawner = Spawner()

tmr_ammo = Timer:new(60 * 2, function() add_ammo(1) end, true)
tmr_spawn = Timer:new(60 * 2, function() spawner:spawn_guy() end, true)
all_clocks:add(tmr_ammo)
all_clocks:add(tmr_spawn)

game_clock = Clock()

mx = 0
my = 0

tmr_ammo:start()
tmr_spawn:start()

function love.load()
    love.mouse.setVisible(false)
    set_bgcolor_from_hex(COLORS.CF_BLUE)
    --change_gamestate(GAME_STATES.game)
    --  high_score = load_high_score()
    if is_debug_on then
        logger.level = logger.Level.DEBUG
        logger.debug("Entering debug mode")
        love.profiler.start()
    else
        logger.level = logger.Level.DEBUG
        logger.info("logger in INFO mode")
    end

    font = love.graphics.newFont("asset/font/quizshow.ttf", 32)
    --font_hud = love.graphics.newFont("asset/font/mago2.ttf", 64)

    background_img = love.graphics.newImage("asset/image/streetCleanersLayout.png")

    font:setFilter("nearest")
    --font_hud:setFilter("nearest")
    love.graphics.setFont(font)

    -- if your code was optimized for fullHD:
    window = {translateX = 0, translateY = 0, scale = 3, width = 384, height = 216}
    width, height = love.graphics.getDimensions()
    love.window.setMode(width, height, {resizable = true, borderless = false})
    resize(width, height) -- update new translation and scale

    start_game()
end

function love.quit()
    logger.info("The game is closing.")
    if is_debug_on then
        love.profiler.stop()
        print(love.profiler.report(30))
    end
end

function love.update(dt)

    if love.keyboard.isDown("w")  then
            mouse.position.y = mouse.position.y - 3
        end
        if love.keyboard.isDown("s")  then
            mouse.position.y = mouse.position.y + 3
        end
        if love.keyboard.isDown("a")  then
            mouse.position.x = mouse.position.x - 3
        end
        if love.keyboard.isDown("d")  then
           mouse.position.x = mouse.position.x + 3
        end


    if show_flash > 0 then
        show_flash = show_flash - 1
    end

    if show_hurt > 0 then
        show_hurt = show_hurt - 1
    end

    -- for _, a in pairs(enemies) do
    --     a:update(dt)
    -- end

    -- for _, b in pairs(blood_container) do
    --     b:update(dt)
    -- end

    -- for _, bh in pairs(bhit_container) do
    --     bh:update(dt)
    -- end

    for _, container in ipairs({enemies, blood_container, bhit_container}) do
        for _, obj in ipairs(container) do
            obj:update(dt)
        end
    end

    mx = math.floor((love.mouse.getX() - window.translateX) / window.scale + 0.5)
    my = math.floor((love.mouse.getY() - window.translateY) / window.scale + 0.5)

    all_clocks:update()

    if game_state == GAME_STATES.game then
        update_game(dt)
    end

    if game_state == GAME_STATES.pause then
        update_pause()
    end

    mouse:update(mx, my)

    --print(#enemies)
    -- print((collectgarbage('count') / 1024))
    --print('Memory used: ' .. string.format("%.2f", collectgarbage('count') / 1000) .. " MB")
end

function love.mousepressed(x, y, button, _)
    --print(button)
    if button == 1 then
       -- shoot()
    elseif button == 2 then
        add_ammo(1)
    end
    --mx = math.floor((x - window.translateX) / window.scale + 0.5)
    --my = math.floor((y - window.translateY) / window.scale + 0.5)

    --print("click on " .. mx .. " " .. my)
end

function shoot()
    if player.ammo >= 1 then
        play_sound(shoot_player)
        player.ammo = math.clamp(0, player.ammo - 1, player.max_ammo)
        show_flash = 0
        show_flash = 2
        --shake_duration=0.1

        local overlaps = {}

        for _, e in pairs(enemies) do
            if e.is_hovered then
                table.insert(overlaps, e)
            end
            --e:check_if_hovered()
        end

        if #overlaps > 0 then
            table.sort(overlaps, get_closer_enemy)

            overlaps[1]:on_hit()
        end
    else
        --TODO: Play empty sound
    end

    -- body
end

function get_closer_enemy(a, b)
    return a.position.y > b.position.y
end

function love.k()
    
end

function love.keypressed(key, scancode, isrepeat)
    if not isrepeat then
        if key == "escape" then
            quit_game()
        end

        if key == "space" then
            shoot()
        end

        if key == "r" then
            love.event.push("quit", "restart")
            
        end
        -- if game_state == GAME_STATES.title then
        -- -- elseif game_state == GAME_STATES.game then
        -- --     if key == "space" then
        -- --         game_state = GAME_STATES.pause
        -- --         is_paused = true
        -- --         return
        -- --     end
        -- -- elseif game_state == GAME_STATES.pause then
        -- --     if key == "space" then
        -- --         --print("on pause pressing pause")
        -- --         game_state = GAME_STATES.game
        -- --         is_paused = false
        -- --         return
        -- --     end
        -- elseif game_state == GAME_STATES.gameover then

        -- end
    end
    
end

function change_gamestate(state)
    if state == GAME_STATES.game then
    end
    game_state = state
end

function love.draw()
    -- first translate, then scale
    love.graphics.translate(window.translateX, window.translateY)
    love.graphics.scale(window.scale)
    -- your graphics code here, optimized for fullHD

    love.graphics.draw(background_img, 0, 0)

    for _, a in pairs(enemies) do
        a:draw()
    end

    love.graphics.draw(wall, 150, 135)

    for _, b in pairs(blood_container) do
        b:draw()
    end

    for _, bh in pairs(bhit_container) do
        bh:draw()
    end

    mouse:draw()

    if game_state == GAME_STATES.title then
        draw_title()
    end

    if game_state == GAME_STATES.game then

    end

    if game_state == GAME_STATES.gameover then
        draw_gameover()
    end

    if show_flash > 0 then
        love.graphics.draw(flash_img, 0, 0)
    end

    if show_hurt > 0 then
        love.graphics.draw(hurt_img, 0, 0)
    end

    hud:draw()

    if game_state == GAME_STATES.pause then
        --draw_game()
        draw_pause()
    end

    --print("Current FPS: "..tostring(love.timer.getFPS( )))
    --print(show_hurt)
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
    game_clock:restart()
    spawner:reset()
    save_high_score(player.score)
    bg_music:stop()
end

function draw_title()

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
    --game_clock:start()
    --spawner:start()
    --high_score = load_high_score()
    change_gamestate(GAME_STATES.game)
    --bg_music:setVolume(5.2)
    bg_music:play()
--    spawner:reset()
end

function reset_game()
    player_score = 0
    change_gamestate(GAME_STATES.title)
    for b in pairs(blood_container) do
        blood_container[b] = nil
    end
end

function update_game(dt)
    flux.update(dt)
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
