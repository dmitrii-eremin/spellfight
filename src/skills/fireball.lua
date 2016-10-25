local Fireball = Class('Fireball', Skill)

Fireball.static.image = love.graphics.newImage('assets/sprites/Projectiles/effects.png')
Fireball.static.grid = Anim8.newGrid(32, 32, Fireball.static.image:getDimensions())

Fireball.static.particle_image = love.graphics.newImage('assets/sprites/flare/corona.png')

function Fireball:initialize(x, y, dir)
    Skill.initialize(self, 8, x, y, dir, 350)

    self.image = Fireball.static.image
    self.animation = Anim8.newAnimation(Fireball.static.grid('1-2', 1), 0.1)

    if dir == -1 then
        self.animation:flipH()
    end

    self.sound_name = 'sounds-explosion_fireball'

    self.particles_count = 150

    self.particles_timer = 1.5
    self.particles = love.graphics.newParticleSystem(Fireball.static.particle_image, self.particles_count)
    self.particles:setParticleLifetime(0.5, self.particles_timer)
    self.particles:setSpread(360)
	self.particles:setLinearAcceleration(-200, -200, 200, 200)
    self.particles:setSpeed(100)
	self.particles:setColors(255, 255, 255, 255,
                             255, 109, 0, 255,
                             255, 228, 0, 255,
                             255, 0, 0, 255,
                             255, 250, 206, 255)

    Signal.emit('sounds-shoot_fireball')
end

return Fireball
