controls_menu = {}

function controls_menu:init()
    self.canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

    self.background = love.graphics.newImage('assets/sprites/Backgrounds/bg.png')
end

function controls_menu:draw()
    self.canvas:renderTo(function()
        love.graphics.clear()

        local bg_x, bg_y = 0, 0
        bg_x = -(self.background:getWidth() - CANVAS_WIDTH) / 2
        bg_y = -(self.background:getHeight() - CANVAS_HEIGHT) / 2
        love.graphics.draw(self.background, bg_x, bg_y, 0)
        love.graphics.setColor(0, 0, 0, 190)
        love.graphics.rectangle('fill', 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)

        love.graphics.setColor(255, 255, 255, 255)

        local font = love.graphics.getFont()
        local font_height = font:getHeight() * 1.5

        love.graphics.setFont(Fonts.mono[18])
        local lines = {
            locale:get('controls', 'player1'),
            '',
            locale:get('controls', 'cast1'),
            locale:get('controls', 'cast1value'),
            '',
            locale:get('controls', 'attack1'),
            locale:get('controls', 'attack1value'),
            '',
            '========================================',
            '',
            locale:get('controls', 'player2'),
            '',
            locale:get('controls', 'cast2'),
            locale:get('controls', 'cast2value'),
            '',
            locale:get('controls', 'attack2'),
            locale:get('controls', 'attack2value'),
            '',
            '========================================',
            '',
            locale:get('controls', 'effect'),
            locale:get('controls', 'fullscreen'),
        }

        local menu_height = #lines * font_height

        local y = (CANVAS_HEIGHT - menu_height) / 2

        for _, v in ipairs(lines) do
            if not v.delimiter then
                love.graphics.printf(v, 0, y, CANVAS_WIDTH, 'center')
            end
            y = y + font_height
        end

        love.graphics.setColor(255, 255, 255, 255)
    end)

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setShader()
    love.graphics.draw(self.canvas, CANVAS_OFFSET_X, CANVAS_OFFSET_Y, 0, CANVAS_SCALE_X, CANVAS_SCALE_Y)
    love.graphics.setShader()
end

function controls_menu:keypressed(key, scancode, is_repeat)
    State.pop()
end

function controls_menu:mousepressed(mx, my, button, istouch)
    State.pop()
end
