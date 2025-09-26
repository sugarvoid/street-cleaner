function love.conf(t)
    t.identity = "streetcleaner"
    t.window.title = "Street Cleaner"
    t.window.icon = "asset/image/icon.png"
    t.window.resizable = true
    t.window.width = 384 * 3
    t.window.height = 216 * 3
    t.window.vsync = 1
    t.window.fullscreen = false
    t.modules.touch = false
    t.console = true --TODO: Remove after debugging.
end
