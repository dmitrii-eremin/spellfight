local DamageManager = Class('DamageManager')

function DamageManager:initialize()
    self.damages = {}
end

function DamageManager:update(dt)
    for i = #self.damages, 1, -1 do
        local v = self.damages[i]
        v.y = v.y - v.speed * dt
        v.timer = v.timer + dt
        if v.timer > v.limit then
            table.remove(self.damages, i)
        end
    end
end

function DamageManager:draw()
    local old_font = love.graphics.getFont()
    love.graphics.setFont(Fonts.mono[12])
    for _, v in ipairs(self.damages) do
        local alpha = 255 * (1 - v.timer / v.limit)
        love.graphics.setColor(255, 255, 255, alpha)
        love.graphics.print(v.text, v.x, v.y)
    end

    love.graphics.setFont(old_font)
    love.graphics.setColor(255, 255, 255, 255)
end

function DamageManager:add(text, x, y)
    table.insert(self.damages, {
        text = text,
        x = x,
        y = y,
        timer = 0,
        limit = 1,
        speed = 50,
    })
end

return DamageManager
