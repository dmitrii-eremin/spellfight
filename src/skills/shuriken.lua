local Shuriken = Class('Shuriken', Skill)

Shuriken.static.image = love.graphics.newImage('assets/sprites/flare/x3.png')
Shuriken.static.grid = Anim8.newGrid(64, 64, Shuriken.static.image:getDimensions())

Shuriken.static.particle_image = love.graphics.newImage('assets/sprites/flare/corona.png')

function Shuriken:initialize(x, y, dir)
    Skill.initialize(self, 18, x, y, dir, 650)

    self.image = Shuriken.static.image
    self.animation = Anim8.newAnimation(Shuriken.static.grid(1, 1), 0.1)

    if dir == -1 then
        self.animation:flipH()
    end

    self.color = {love.math.random(0, 128), love.math.random(0, 128), love.math.random(0, 128), 255}
    self.blend_mode = 'add'

    self.offset_x = -32
    self.offset_y = -16

    self.sound_name = 'sounds-explosion_shuriken'

    self.particles_count = 1000

    self.particles_timer = 2.5
    self.particles = love.graphics.newParticleSystem(Shuriken.static.particle_image, self.particles_count)
    self.particles:setParticleLifetime(1.0, self.particles_timer)
    self.particles:setSpread(360)
	self.particles:setLinearAcceleration(-200, -200, 200, 200)
    self.particles:setSpeed(50)
	self.particles:setColors(unpack(self.color))

    Signal.emit('sounds-shoot_shuriken')    
end

function Shuriken:update(dt)
    Skill.update(self, dt)
    self.angle = self.angle + 25 * dt
end

function Shuriken:draw()
    if self.dead then
        Skill.draw(self)
    else
        Skill.draw(self)
        Skill.draw(self)
        Skill.draw(self)
    end
end

return Shuriken
