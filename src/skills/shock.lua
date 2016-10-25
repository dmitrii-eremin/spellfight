local Shock = Class('Shock', Skill)

Shock.static.image = love.graphics.newImage('assets/sprites/Projectiles/shock.png')
Shock.static.grid = Anim8.newGrid(64, 64, Shock.static.image:getDimensions())

Shock.static.particle_image = love.graphics.newImage('assets/sprites/flare/sparkle.png')

function Shock:initialize(x, y, dir)
    Skill.initialize(self, 38, x, y, dir, 750)

    self.image = Shock.static.image
    self.animation = Anim8.newAnimation(Shock.static.grid('1-4', 1, '1-4', 5), 0.01)

    if dir == -1 then
        self.animation:flipH()
    end

    self.offset_x = -32
    self.offset_y = -16

    self.sound_name = 'sounds-explosion_shock'

    self.particles_count = 450

    self.particles_timer = 0.5
    self.particles = love.graphics.newParticleSystem(Shock.static.particle_image, self.particles_count)
    self.particles:setParticleLifetime(0.1, self.particles_timer)
    self.particles:setSpread(360)
	self.particles:setLinearAcceleration(-50, -50, 50, 50)
    self.particles:setSpeed(100)
	self.particles:setColors(126, 140, 255, 255,
                             107, 209, 255, 255,
                             61, 123, 255, 255,
                             56, 114, 265, 255,
                             255, 255, 255, 255)

    Signal.emit('sounds-shoot_shock')
end

return Shock
