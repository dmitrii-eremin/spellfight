require 'src.globals'

function love.directorydropped(path)

end

function love.draw()
    if use_effect then
        post_effect:draw(function()
            State.current():draw()
        end)
    else
        State.current():draw()
    end

    if DEBUG then
        local stats = love.graphics.getStats()

        local info = {
            'FPS: ' .. love.timer.getFPS(),
            'Memory: ' .. Lume.round(collectgarbage('count') / 1024, 0.1) .. 'MB',
        }

        Lume.push(info,
            'Draw calls: ' .. stats.drawcalls,
            'Texture memory: ' .. Lume.round(stats.texturememory / 1024 / 1024, 0.01) .. 'MB',
            'Images: ' .. stats.images,
            'Fonts: ' .. stats.fonts,
            'Canvases: ' .. stats.canvases)

        love.graphics.push()
        love.graphics.setColor(255, 255, 255)

        local font = Fonts.mono[18]
        love.graphics.setFont(font)

        for i, text in ipairs(info) do
            love.graphics.print(text, 10, 10 + (i - 1) * font:getHeight() * 1.3)
        end

        love.graphics.pop()
    end
end

function love.filedropped(file)

end

function love.focus(focus)

end

function love.keypressed(key, scancode, isrepeat)
    if key == 'f1' and love.keyboard.isDown('lctrl', 'rctrl') then
        DEBUG = not DEBUG
    elseif key == 'escape' and love.keyboard.isDown('lshift', 'rshift') then
        love.event.quit()
    elseif key == 'f11' then
        local w, h, f = love.window.getMode()
        f.fullscreen = not f.fullscreen
        love.window.setMode(w, h, f)
    elseif key == 'f3' then
        use_effect = not use_effect
    end
end

function love.keyreleased(key, scancode)

end

function love.load(argv)
    local makeFont = function(path)
        return setmetatable({}, {
            __index = function(t, size)
                local font = love.graphics.newFont(path, size)
                rawset(t, size, font)
                return font
            end
        })
    end

    Fonts = {
        default = makeFont('assets/fonts/pixel.ttf'),
        mono = makeFont('assets/fonts/pixel.ttf'),
    }

    love.graphics.setFont(Fonts.default[24])

    local callbacks = {'update'}
    for callback_name in pairs(love.handlers) do
        table.insert(callbacks, callback_name)
    end

    local grain = Shine.filmgrain()
    grain.opacity = 0.2
    local vignette = Shine.vignette()
    local crt = Shine.crt()
    vignette.parameters = {radius = 0.9, opacity = 0.7}
    local desaturate = Shine.desaturate{strength = 0.6, tint = {255,250,200}}

    post_effect = desaturate:chain(grain):chain(vignette):chain(crt)
    post_effect.opacity = 0.5

    use_effect = false

    State.registerEvents(callbacks)
    State.switch(main_menu)
end

function love.lowmemory()

end

function love.mousefocus(focus)

end

function love.mousemoved(x, y, dx, dy, istouch)

end

function love.mousepressed(x, y, button, istouch)

end

function love.mousereleased(x, y, button, istouch)

end

function love.quit()

end

function love.resize(w, h)
    local sw, sh = love.graphics.getDimensions()

    local scale_x = sw / CANVAS_WIDTH
    local scale_y = sh / CANVAS_HEIGHT

    local scale = math.min(scale_x, scale_y)

    CANVAS_SCALE_X = scale
    CANVAS_SCALE_Y = scale

    local rw, rh = CANVAS_WIDTH * scale, CANVAS_HEIGHT * scale

    CANVAS_OFFSET_X = (sw - rw) / 2
    CANVAS_OFFSET_Y = (sh - rh) / 2
end

function love.textedited(text, start, length)

end

function love.textinput(text)

end

function love.touchmoved(id, x, y, dx, dy, pressure)

end

function love.touchpressed(id, x, y, dx, dy, pressure)

end

function love.touchreleased(id, x, y, dx, dy, pressure)

end

function love.update(dt)

end

function love.visible(isvisible)

end

function love.wheelmoved(x, y)

end

function love.gamepadaxis(joystick, axis, value)

end

function love.gamepadpressed(joystick, button)

end

function love.gamepadreleased(joystick, button)

end

function love.joystickadded(joystick)

end

function love.joystickaxis(joystick, axis, value)

end

function love.joystickhat(joystick, hat, direction)

end

function love.joystickpressed(joystick, button)

end

function love.joystickreleased(joystick, button)

end

function love.joystickremoved(joystick)

end
