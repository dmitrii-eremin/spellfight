local Sounds = Class('Sounds')

function Sounds:initialize()
    self.change = love.audio.newSource('assets/sounds/change.wav', 'static')
    self.select = love.audio.newSource('assets/sounds/select.wav', 'static')

    self.p1_cast = love.audio.newSource('assets/sounds/p1_cast.wav', 'static')
    self.p2_cast = love.audio.newSource('assets/sounds/p2_cast.wav', 'static')

    self.hurt = love.audio.newSource('assets/sounds/hurt.wav', 'static')
    self.dead = love.audio.newSource('assets/sounds/dead.wav', 'static')

    self.explosion_iceball = love.audio.newSource('assets/sounds/explosion_iceball.wav', 'static')
    self.explosion_fireball = love.audio.newSource('assets/sounds/explosion_fireball.wav', 'static')
    self.explosion_shuriken = love.audio.newSource('assets/sounds/explosion_shuriken.wav', 'static')
    self.explosion_flame = love.audio.newSource('assets/sounds/explosion_flame.wav', 'static')
    self.explosion_shock = love.audio.newSource('assets/sounds/explosion_shock.wav', 'static')

    self.shoot_iceball = love.audio.newSource('assets/sounds/shoot_iceball.wav', 'static')
    self.shoot_fireball = love.audio.newSource('assets/sounds/shoot_fireball.wav', 'static')
    self.shoot_shuriken = love.audio.newSource('assets/sounds/shoot_shuriken.wav', 'static')
    self.shoot_flame = love.audio.newSource('assets/sounds/shoot_flame.wav', 'static')
    self.shoot_shock = love.audio.newSource('assets/sounds/shoot_shock.wav', 'static')

    self.intro = love.audio.newSource('assets/music/intro.wav')
    self.intro:setLooping(true)

    self.gamerun = love.audio.newSource('assets/music/run.wav')
    self.gamerun:setLooping(true)

    local explosions = {'iceball', 'fireball', 'shuriken', 'flame', 'shock'}

    Signal.register('music-intro', function()
        self.gamerun:stop()
        self.intro:stop()
        self.intro:play()
    end)

    Signal.register('music-game-run', function()
        self.intro:stop()
        if self.gamerun:isStopped() then
            self.gamerun:play()
        else
            self.gamerun:resume()
        end
    end)

    Signal.register('music-game-pause', function()
        self.gamerun:pause()
    end)

    Signal.register('sounds-hurt', function()
        self.hurt:stop()
        self.hurt:play()
    end)

    Signal.register('sounds-dead', function()
        self.dead:stop()
        self.dead:play()
    end)

    Signal.register('sounds-change', function()
        self.change:stop()
        self.change:play()
    end)

    Signal.register('sounds-select', function()
        self.select:stop()
        self.select:play()
    end)

    Signal.register('sounds-beep', function()
        self.select:stop()
        self.select:play()
    end)

    Signal.register('sounds-cast', function(index)
        local name = string.format('p%d_cast', index)
        self[name]:stop()
        self[name]:play()
    end)

    for _, v in ipairs(explosions) do
        local sound_name = string.format('sounds-explosion_%s', v)
        local item_name = string.format('explosion_%s', v)

        Signal.register(sound_name, function()
            self[item_name]:stop()
            self[item_name]:play()
        end)

        local sound_name = string.format('sounds-shoot_%s', v)
        local item_name = string.format('shoot_%s', v)

        Signal.register(sound_name, function()
            self[item_name]:stop()
            self[item_name]:play()
        end)
    end
end

return Sounds
