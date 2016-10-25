credits_menu = {}

function credits_menu:init()
    self.canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

    self.background = love.graphics.newImage('assets/sprites/Backgrounds/bg.png')
end

function credits_menu:draw()
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
            locale:get('credits', 'code'),
            'Eremin Dmitry',
            'https://github.com/NeonMercury',
            '',
            locale:get('credits', 'art'),
            'http://www.kenney.nl',
            'http://hackcraft.de',
            'http://www.physhexgames.co.nr',
            'http://opengameart.org/content/pixelantasy',
            'http://opengameart.org/content/arrow-keys-wsad-mouse-icon',
            'http://opengameart.org/content/old-parchment-paper',
            '',
            locale:get('credits', 'music'),
            'Snabisch',
            ''
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

function credits_menu:keypressed(key, scancode, is_repeat)
    State.pop()
end

function credits_menu:mousepressed(mx, my, button, istouch)
    State.pop()
end
