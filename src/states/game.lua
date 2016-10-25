game = {}

function game:init()
    self.canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

    love.graphics.setDefaultFilter('nearest', 'nearest')

    self.background = love.graphics.newImage('assets/sprites/Backgrounds/bg.png')
    self.help = love.graphics.newImage('assets/sprites/hp/help.png')

    self:reset()

    Signal.emit('music-game-run')
end

function game:reset()
    self.players = {
        Player('wizard', 95, 92),
        Player('warlock', 465, 90),
    }

    self.arrows = ArrowManager()
    self.damages = DamageManager()
    self.skills = {}

    self.wins = nil

    self.shake_timer = nil

    self:pause()
    self:unpause()

    self.timer = Timer()

    self.shock_count = nil
    self.shock_time = nil
    self.shock_alpha = nil
end

function game:pause()
    -- if not self.paused and not self.pause_timer then
        self.paused = true
        self.pause_timer = 3
    -- end

    Signal.emit('music-game-pause')
end

function game:unpause()
    self.paused = false

    Signal.emit('music-game-run')
end

function game:toggle_pause()
    if self.paused then
        self:unpause()
    else
        self:pause()
    end
end

function game:enter(from, level_name)
    Signal.emit('game_entered')
end

function game:update(dt)
    if not self.paused and not self.pause_timer then
        for _, v in ipairs(self.players) do
            v:update(dt)
        end

        self.arrows:update(dt)
        self:update_skills(dt)
        self.damages:update(dt)

        if not self.wins then
            self.timer:update(dt)

            if self.ai then
                self.ai:update(dt)
            end

            if self.ai and self.players[2]:can_cast() then
                if not self.ai:is_plan_ready() then
                    if self.ai.time_to_attack then
                        self.ai:attack(self.players[2], self.skills)
                    else
                        self.ai:generate_new_plan()
                    end
                end

                if self.players[2]:can_cast() then
                    self.ai:cast(self.players[2], self.arrows)
                end
            end
        end
    end

    if self.pause_timer and not self.paused then
        local int_value = math.ceil(self.pause_timer)
        self.pause_timer = self.pause_timer - dt
        if math.ceil(self.pause_timer) < int_value then
            Signal.emit('sounds-beep')
        end
        if self.pause_timer <= 0 then
            self.pause_timer = nil
        end
    end

    if self.shake_timer then
        self.shake_timer = self.shake_timer - dt
        if self.shake_timer <= 0 then
            self.shake_timer = nil
        end
    end

    if self.shock_count then
        if not self.shock_time then
            self.shock_alpha = love.math.random(192, 255)
            self.shock_time = 0.05
        end

        self.shock_time = self.shock_time - dt
        if self.shock_time <= 0 then
            self.shock_time = nil
            self.shock_count = self.shock_count - 1
            if self.shock_count <= 0 then
                self.shock_count = nil
                self.shock_time = nil
                self.shock_alpha = nil
            end
        end
    end
end

function game:update_skills(dt)

    if self.players[1].dead and self.players[2].dead then
        self.wins = 0
    elseif self.players[1].dead then
        self.wins = 2
    elseif self.players[2].dead then
        self.wins = 1
    end

    for i = #self.skills, 1, -1 do
        local s = self.skills[i]
        s:update(dt)

        local damage_applied = false

        if s.dir == 1 and s.x > self.players[2].x and not s.dead then
            if self.players[2]:on_hit(s.damage) then
                local x, y = self.players[2]:get_center()
                y = y - 32
                self.damages:add(s.damage, x, y)
                damage_applied = true
            end
            self.skills[i]:on_collide()
        elseif s.dir == -1 and s.x < self.players[1].x + 32 and not s.dead then
            if self.players[1]:on_hit(s.damage) then
                local x, y = self.players[1]:get_center()
                y = y - 32
                self.damages:add(s.damage, x, y)
                damage_applied = true
            end
            self.skills[i]:on_collide()
        end

        if damage_applied then
            if s.damage >= 25 then
                self.shake_timer = 0.75
            end

            if s:isInstanceOf(Shock) then
                self.shock_count = 15
            end
        end
    end

    for i = #self.skills, 1, -1 do
        local s1 = self.skills[i]

        if s1.collidable and not s1.dead then
            for j = #self.skills, 1, -1 do
                local s2 = self.skills[j]

                if s2.collidable and s1.dir ~= s2.dir and not s2.dead then
                    local left, right = nil, nil
                    if s1.dir == 1 then
                        left, right = s1, s2
                    else
                        left, right = s2, s1
                    end

                    if left.x + 16 > right.x then
                        if s1.damage > s2.damage then
                            s2:on_collide()
                        elseif s1.damage < s2.damage then
                            s1:on_collide()
                        else
                            s1:on_collide()
                            s2:on_collide()
                        end
                    end
                end
            end
        end
    end

    for i = #self.skills, 1, -1 do
        if self.skills[i].dead and self.skills[i].remove then
            table.remove(self.skills, i)
        end
    end
end

function game:draw()
    local draw_function = function()
        self.canvas:renderTo(function()
            love.graphics.push()
            love.graphics.scale(SCALE)
            if self.shake_timer then
                local offset_x = love.math.random(-10, 10)
                local offset_y = love.math.random(-10, 10)
                love.graphics.translate(offset_x, offset_y)
            end
            love.graphics.clear(0, 0, 0, 255)

            local bg_x, bg_y = 0, 0
            bg_x = -(self.background:getWidth() - CANVAS_WIDTH) / (2 * SCALE)
            bg_y = -(self.background:getHeight() - CANVAS_HEIGHT) / (2 * SCALE)
            love.graphics.draw(self.background, bg_x, bg_y, 0, 0.5)

            self.players[1]:draw()
            self.players[2]:draw()

            self.arrows:draw()

            for _, s in ipairs(self.skills) do
                s:draw()
            end

            self.damages:draw()

            if self.shock_count and self.shock_count % 2 ~= 0 then
                love.graphics.setColor(255, 255, 255, self.shock_alpha)
                love.graphics.rectangle('fill', 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
            end

            love.graphics.pop()
        end)

        self.canvas:renderTo(function()
            if not self.paused and not self.pause_timer then
                self:draw_hp()
                self:draw_mp()
            end

            if self.wins then
                local text = ''
                if self.wins ~= 0 then
                    text = string.format(locale:get('win_title'), self.wins)
                    self.players[self.wins].wins = true
                else
                    text = locale:get('dead_heat')
                end

                local old_font = love.graphics.getFont()
                love.graphics.setFont(Fonts.mono[74])
                love.graphics.printf(text, 0, 100, CANVAS_WIDTH, 'center')

                local secs = self.timer:to_seconds()
                love.graphics.setFont(Fonts.mono[36])
                love.graphics.printf(string.format(locale:get('elapsed_time_title'), secs), 0, 200, CANVAS_WIDTH, 'center')

                love.graphics.setFont(Fonts.mono[24])
                love.graphics.setColor(0, 0, 0, 255)
                love.graphics.printf(locale:get('win_info'), 0, CANVAS_HEIGHT - 80, CANVAS_WIDTH, 'center')
                love.graphics.setFont(old_font)
            elseif self.paused then
                love.graphics.draw(self.help, (CANVAS_WIDTH - self.help:getWidth()) / 2, CANVAS_HEIGHT - self.help:getHeight() - 20)

                local old_font = love.graphics.getFont()
                love.graphics.setFont(Fonts.mono[74])
                love.graphics.printf(locale:get('paused'), 0, 20, CANVAS_WIDTH, 'center')
                love.graphics.setFont(Fonts.mono[24])
                love.graphics.setColor(0, 0, 0, 255)
                love.graphics.printf(locale:get('pause_info'), 0, CANVAS_HEIGHT - 80, CANVAS_WIDTH, 'center')
                love.graphics.setFont(old_font)
            elseif self.pause_timer then
                love.graphics.draw(self.help, (CANVAS_WIDTH - self.help:getWidth()) / 2, CANVAS_HEIGHT - self.help:getHeight() - 20)

                local old_font = love.graphics.getFont()
                love.graphics.setFont(Fonts.mono[74])
                love.graphics.printf(string.format('%d', math.ceil(self.pause_timer)), 0, 20, CANVAS_WIDTH, 'center')
                love.graphics.setFont(old_font)
            else
                local secs = self.timer:to_seconds()

                local old_font = love.graphics.getFont()
                love.graphics.setFont(Fonts.mono[24])
                love.graphics.printf(string.format('%d', math.ceil(secs)), 0, 20, CANVAS_WIDTH, 'center')
                love.graphics.setFont(old_font)
            end
        end)

        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.clear(0, 0, 0, 255)
        love.graphics.draw(self.canvas, CANVAS_OFFSET_X, CANVAS_OFFSET_Y, 0, CANVAS_SCALE_X, CANVAS_SCALE_Y)

    end

    -- if self.use_effect then
    --     self.post_effect:draw(draw_function)
    -- else
    --     draw_function()
    -- end
    draw_function()
end

function game:draw_hp()
    local hp_color = {200, 0, 0, 255}

    local p1_x = 50
    local p2_x = CANVAS_WIDTH - Player.static.hp_foreground_image:getWidth() - 50
    local p_y = CANVAS_HEIGHT - 50 - 28

    local p1_hp_scale = self.players[1].hp / self.players[1].max_hp
    love.graphics.setColor(unpack(hp_color))
    love.graphics.rectangle('fill', p1_x + 12, p_y + 8, (256 - 12 * 2) * p1_hp_scale, 32 - 8 * 2)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(Player.static.hp_foreground_image, p1_x, p_y)

    local p2_hp_scale = self.players[2].hp / self.players[2].max_hp
    love.graphics.setColor(unpack(hp_color))
    love.graphics.rectangle('fill', p2_x + 12, p_y + 8, (256 - 12 * 2) * p2_hp_scale, 32 - 8 * 2)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(Player.static.hp_foreground_image, p2_x, p_y)
end

function game:draw_mp()
    local mp_color = {0, 0, 200, 255}
    local p1_x = 50
    local p2_x = CANVAS_WIDTH - Player.static.hp_foreground_image:getWidth() - 50
    local p_y = CANVAS_HEIGHT - 50

    local p1_mp_scale = self.players[1].mp / self.players[1].max_mp
    love.graphics.setColor(unpack(mp_color))
    love.graphics.rectangle('fill', p1_x + 12, p_y + 8, (256 - 12 * 2) * p1_mp_scale, 32 - 8 * 2)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(Player.static.hp_foreground_image, p1_x, p_y)

    local p2_mp_scale = self.players[2].mp / self.players[2].max_mp
    love.graphics.setColor(unpack(mp_color))
    love.graphics.rectangle('fill', p2_x + 12, p_y + 8, (256 - 12 * 2) * p2_mp_scale, 32 - 8 * 2)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(Player.static.hp_foreground_image, p2_x, p_y)
end

function game:keypressed(key, scancode, is_repeat)
    local index = 0
    local attack = false
    local cast = false

    if not self.paused and not self.pause_timer then
        if key == 'lctrl' or key == 'rctrl' or key == 'lshift' or key == 'rshift' then
            attack = true
            index = (key == 'lctrl' or key == 'lshift') and 1 or 2
        end

        if key == 'a' or key == 'w' or key == 's' or key == 'd' then
            cast = true
            index = 1
        end

        if key == 'left' or key == 'up' or key == 'down' or key == 'right' then
            cast = true
            index = 2
        end
    end

    if self.ai and index == 2 then
        index = 0
        attack = false
        cast = false
    end

    if attack then
        local combo = self.players[index]:get_combo()
        local SkillCtor = Recipes[combo]

        if self.players[index]:attack() then
            if not SkillCtor then
                self.players[index]:on_hit(0)
            else
                local x, y = self.players[index]:get_center()
                y = y - 16
                if index == 2 then
                    x = x - 32
                end

                local skill = SkillCtor(x, y, index == 1 and 1 or -1)

                table.insert(self.skills, skill)
            end
        end
    end

    if cast then
        Signal.emit('sounds-cast', index)
        if self.players[index]:cast() then
            self.players[index]:add_combo(key)

            local x, y = self.players[index]:get_center()
            y = y - 64
            self.arrows:add(key, index, x, y)
        end
    end

    if key == 'escape' then
        if self.wins then
            State.switch(main_menu)
        else
            self:toggle_pause()
        end
        Signal.emit('sounds-beep')
    elseif key == 'space' and self.wins then
        self:reset()
        Signal.emit('sounds-beep')
    elseif key == 'space' and self.paused then
        State.switch(main_menu)
        Signal.emit('sounds-beep')
    end
end
--
-- function game:mousepressed(mx, my, button, istouch)
--     print(mx, my)
--     local CW3 = CANVAS_WIDTH / 3
--     local CH3 = CANVAS_HEIGHT / 3
--
--     local areas = {
--         lt = false, t = false, rt = false,
--         l = false, c = false, r = false,
--         lb = false, b = false, rb = false,
--     }
--
--     if mx < CW3 then
--         if my < CH3 then
--             areas.lt = true
--         elseif my > 2 * CH3 then
--             areas.lb = true
--         else
--             areas.l = true
--         end
--     elseif mx > 2 * CW3 then
--         if my < CH3 then
--             areas.rt = true
--         elseif my > 2 * CH3 then
--             areas.rb = true
--         else
--             areas.r = true
--         end
--     else
--         if my < CH3 then
--             areas.t = true
--         elseif my > 2 * CH3 then
--             areas.b = true
--         else
--             areas.c = true
--         end
--     end
--
--     if areas.l then
--         self:keypressed('a', 'a', false)
--     end
--     if areas.r then
--         self:keypressed('d', 'd', false)
--     end
--     if areas.b then
--         self:keypressed('s', 's', false)
--     end
--     if areas.t then
--         self:keypressed('w', 'w', false)
--     end
--     if areas.c then
--         self:keypressed('lctrl', 'lctrl', false)
--     end
-- end
