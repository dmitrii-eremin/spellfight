local Skill = Class('Skill')

function Skill:initialize(damage, x, y, dir, speed)

    speed = speed or 150
    self.damage = damage or 0

    self.image = nil
    self.animation = nil

    self.x, self.y = x, y
    self.dir = dir
    self.speed = speed

    self.particles = nil
    self.particles_timer = 0

    self.collidable = true

    self.dead = false
    self.remove = false

    self.angle = 0

    self.color = {255, 255, 255, 255}
end

function Skill:on_collide()
    self.dead = true
    if self.particles then
        self.particles:emit(self.particles_count or 500)
        if self.sound_name then
            Signal.emit(self.sound_name)
        end
    end
end

function Skill:update(dt)
    if not self.dead then
        self.animation:update(dt)

        self.x = self.x + self.speed * dt * self.dir
    else
        if self.particles then
            self.particles:update(dt)
        end

        self.particles_timer = self.particles_timer - dt
        if self.particles_timer <= 0 then
            self.remove = true
        end
    end
end

function Skill:draw()
    local old_mode = love.graphics.getBlendMode()

    if not self.dead then
        local x = self.x
        local y = self.y
        if self.offset_x and self.dir > 0 then
            x = x + self.offset_x
        end
        if self.offset_y then
            y = y + self.offset_y
        end
        love.graphics.setBlendMode(self.blend_mode or 'alpha')
        local old_color = {love.graphics.getColor()}
        love.graphics.setColor(unpack(self.color))
        self.animation:draw(self.image, x, y)
        love.graphics.setColor(unpack(old_color))
        love.graphics.setBlendMode(old_mode)
    else
        if self.particles then
            love.graphics.setBlendMode('add')
            love.graphics.draw(self.particles, self.x + 16, self.y + 16)
            love.graphics.setBlendMode(old_mode)
        end
    end
end

return Skill
