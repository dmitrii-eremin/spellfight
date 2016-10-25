main_menu = {}

function main_menu:init()
    self.canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

    self.background = love.graphics.newImage('assets/sprites/Backgrounds/bg.png')

    self.items = {
        {title = 'ai', selected = true, callback = function()
            game.ai = AI()
            game:reset()
            State.push(game)
        end },
        {title = 'player', selected = false, callback = function()
            game.ai = nil
            game:reset()
            State.push(game)
        end },
        {title = 'controls', selected = false, callback = function()
            State.push(controls_menu)
        end },
        {title = 'language', selected = false, callback = function()
            locale:next_language()
        end },
        {title = 'credits', selected = false, callback = function()
            State.push(credits_menu)
        end },
        {title = 'quit', selected = false, callback = function()
            love.event.quit()
        end },
    }
end

function main_menu:enter(from, ...)
    Signal.emit('music-intro')
end

function main_menu:update(dt)

end

function main_menu:draw()
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
        local font_height = font:getHeight() * 1.8

        local menu_height = #self.items * font_height

        local y = (CANVAS_HEIGHT - menu_height) / 2

        love.graphics.setFont(Fonts.mono[40])
        love.graphics.printf('Spellfight', 0, 100, CANVAS_WIDTH, 'center')

        love.graphics.setFont(Fonts.mono[24])

        for _, v in ipairs(self.items) do
            if not v.delimiter then
                local color = {255, 255, 255, 255}
                local s = locale:get('main_menu', v.title)

                if v.selected then
                    s = '>    ' .. s .. '    <'
                end
                if v.disabled then
                    color = {120, 120, 120, 255}
                end

                love.graphics.setColor(unpack(color))
                love.graphics.printf(s, 0, y, CANVAS_WIDTH, 'center')
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

function main_menu:get_selected_index()
    local index = 0
    for i = 1, #self.items do
        local item = self.items[i]
        if item.selected then
            index = i
            break
        end
    end

    assert(index > 0)

    return index
end

function main_menu:select()
    local index = self:get_selected_index()
    local callback = self.items[index].callback
    assert(type(callback) == 'function')

    callback()
end

function main_menu:next()
    local index = self:get_selected_index()
    self.items[index].selected = false

    index = index % #self.items + 1
    while self.items[index].disabled or self.items[index].delimiter do
        index = index % #self.items + 1
    end

    self.items[index].selected = true
end

function main_menu:prev()
    local index = self:get_selected_index()
    self.items[index].selected = false

    index = index - 1
    if index <= 0 then
        index = #self.items
    end
    while self.items[index].disabled or self.items[index].delimiter do
        index = index - 1
        if index <= 0 then
            index = #self.items
        end
    end

    self.items[index].selected = true
end

function main_menu:keypressed(key, scancode, is_repeat)
    if key == 'down' or key == 's' then
        self:next()
        Signal.emit('sounds-change')
    elseif key == 'up' or key == 'w' then
        self:prev()
        Signal.emit('sounds-change')
    elseif key == 'return' or key == 'space' then
        self:select()
        Signal.emit('sounds-select')
    end
end
--
-- function main_menu:mousepressed(mx, my, button, istouch)
--     local font = love.graphics.getFont()
--     local font_height = font:getHeight() * 1.8
--
--     local menu_height = #self.items * font_height
--
--     local y = (CANVAS_HEIGHT - menu_height) / 2
--
--
--     for _, v in ipairs(self.items) do
--         if not v.delimiter then
--             local color = {255, 255, 255, 255}
--             local s = locale:get('main_menu', v.title)
--
--             if v.selected then
--                 s = '>    ' .. s .. '    <'
--             end
--             if v.disabled then
--                 color = {120, 120, 120, 255}
--             end
--
--             print(my, y, y + font_height)
--             if my >= y and my <= y + font_height then
--                 print(my, y, y + font_height)
--                 local callback = v.callback
--                 assert(type(callback) == 'function')
--
--                 callback()
--             end
--         end
--         y = y + font_height
--     end
-- end
