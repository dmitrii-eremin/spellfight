local Iceball = Class('Iceball', Skill)

Iceball.static.image = love.graphics.newImage('assets/sprites/Projectiles/effects.png')
Iceball.static.grid = Anim8.newGrid(32, 32, Iceball.static.image:getDimensions())

function Iceball:initialize(x, y, dir)
    Skill.initialize(self, 7, x, y, dir, 350)

    self.image = Iceball.static.image
    self.animation = Anim8.newAnimation(Iceball.static.grid('3-4', 1), 0.1)

    if dir == -1 then
        self.animation:flipH()
    end

    self.sound_name = 'sounds-explosion_iceball'

    self.particles_count = 75

    self.particles_timer = 1
    self.particles = love.graphics.newParticleSystem(Fireball.static.particle_image, self.particles_count)
    self.particles:setParticleLifetime(0.25, self.particles_timer)
    self.particles:setSpread(360)
	self.particles:setLinearAcceleration(-100, -100, 100, 100)
    self.particles:setSpeed(50)
	self.particles:setColors(206, 244, 255, 255,
                             66, 213, 255, 255,
                             134, 228, 255, 255,
                             255, 255, 255, 255)

    Signal.emit('sounds-shoot_iceball')
end

return Iceball
