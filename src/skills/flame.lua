local Flame = Class('Flame', Skill)

Flame.static.image = love.graphics.newImage('assets/sprites/Projectiles/hd_flame_0.png')
Flame.static.grid = Anim8.newGrid(64, 64, Flame.static.image:getDimensions())

Flame.static.particle_image = love.graphics.newImage('assets/sprites/flare/corona.png')

function Flame:initialize(x, y, dir)
    Skill.initialize(self, 25, x, y, dir, 500)

    self.image = Flame.static.image
    self.animation = Anim8.newAnimation(Flame.static.grid(1, 1), 0.1)

    if dir == -1 then
        self.animation:flipH()
    end

    self.offset_x = -32
    self.offset_y = -16

    self.sound_name = 'sounds-explosion_flame'
    self.blend_mode = 'add'

    self.particles_count = 450

    self.particles_timer = 1.5
    self.particles = love.graphics.newParticleSystem(Flame.static.particle_image, self.particles_count)
    self.particles:setParticleLifetime(0.5, self.particles_timer)
    self.particles:setSpread(1 * self.dir)
	self.particles:setLinearAcceleration(-600, -400, 600, 800)
    self.particles:setSpeed(100)
	self.particles:setColors(238, 75, 150, 255,
                             127, 12, 170, 255,
                             216, 74, 238, 255,
                             255, 0, 0, 255,
                             255, 250, 206, 255)

    Signal.emit('sounds-shoot_flame')
end

return Flame
