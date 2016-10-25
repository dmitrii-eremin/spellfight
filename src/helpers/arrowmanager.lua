local ArrowManager = Class('ArrowManager')

function ArrowManager:initialize()
    self.arrows = {
        up = love.graphics.newImage('assets/sprites/arrows/White/1x/arrowUp.png'),
        down = love.graphics.newImage('assets/sprites/arrows/White/1x/arrowDown.png'),
        left = love.graphics.newImage('assets/sprites/arrows/White/1x/arrowLeft.png'),
        right = love.graphics.newImage('assets/sprites/arrows/White/1x/arrowRight.png'),
    }

    self.history = {}
end

function ArrowManager:update(dt)
    for i = #self.history, 1, -1 do
        local a = self.history[i]
        a.timer = a.timer + dt
        if a.timer > a.limit then
            table.remove(self.history, i)
        end
    end
end

function ArrowManager:draw()
    for _, v in ipairs(self.history) do
        local alpha = math.floor(255 * (1 - v.timer / v.limit))
        local scale = v.timer * (v.final_scale - 1) / v.limit + 1

        love.graphics.setColor(255, 255, 255, alpha)

        local offset_x = v.x - v.image:getWidth() / 2 * scale
        local offset_y = v.y - v.image:getHeight() / 2 * scale

        love.graphics.draw(v.image, offset_x, offset_y, 0, scale)
    end

    love.graphics.setColor(255, 255, 255, 255)
end

function ArrowManager:add(key, id, x, y)
    local image_type = nil
    if key == 'a' or key == 'left' then
        image_type = 'left'
    elseif key == 'd' or key == 'right' then
        image_type = 'right'
    elseif key == 'w' or key == 'up' then
        image_type = 'up'
    elseif key == 's' or key == 'down' then
        image_type = 'down'
    end

    if image_type then
        table.insert(self.history, {
            image = self.arrows[image_type],
            timer = 0,
            limit = 0.2,
            final_scale = 2,
            x = x,
            y = y,
            id = id,
        })
    end
end

return ArrowManager
