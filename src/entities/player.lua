local Player = Class('Player')

Player.static.wizard = love.graphics.newImage('assets/sprites/Characters/Wizard 1/warlock.png')
Player.static.warlock = love.graphics.newImage('assets/sprites/Characters/Wizard 1/wizard.png')
Player.static.grid = Anim8.newGrid(64, 64, Player.static.wizard:getDimensions())

Player.static.hp_background_image = love.graphics.newImage('assets/sprites/hp/enemy_health_bar_000.png')
Player.static.hp_foreground_image = love.graphics.newImage('assets/sprites/hp/enemy_health_bar_foreground_001.png')

function Player:initialize(player_type, x, y)
    self.type = player_type or 'wizard'

    self.x, self.y = x, y

    self.image = Player.static[self.type]
    self.image:setFilter('nearest', 'nearest')

    self.max_hp = 100
    self.hp = self.max_hp

    self.max_mp = 75
    self.mp = self.max_mp

    local g = Player.static.grid
    self.animations = {
        idle = Anim8.newAnimation(g(1, 1), 1),
        cast = Anim8.newAnimation(g('2-5', 1, '4-2', 1), 0.1),
        attack = Anim8.newAnimation(g(5, 1), 1),
        hit = Anim8.newAnimation(g('6-7', 2), 0.1),
        dead = Anim8.newAnimation(g('1-5', 2), {0.1, 0.1, 0.1, 0.1, 10000}),
    }

    if self.type ~= 'wizard' then
        for _, a in pairs(self.animations) do
            a:flipH()
        end
    end

    self.animation = self.animations.idle
    self.casting = false

    self.hit = false
    self.hit_cooldown = 1
    self.hit_timer = 0

    self.attacking = false
    self.attack_timer = 0
    self.attack_cooldown = self.hit_cooldown * 1.5


    self.dead = false

    self.combo = {}
end

function Player:can_cast()
    return not self.dead and not self.attacking and not self.hit
end

function Player:reset(world)

end

function Player:update(dt)
    if self.dead then
        self.animation = self.animations.dead
    elseif self.wins then
        self.animation = self.animations.cast
    end
    self.animation:update(dt)

    if self.attacking then
        self.attack_timer = self.attack_timer + dt
        if self.attack_timer > self.attack_cooldown then
            self.attack_timer = 0
            self.attacking = false
            self.animation = self.animations.idle
        end
    end

    if self.hit then
        self.hit_timer = self.hit_timer + dt
        if self.hit_timer > self.hit_cooldown then
            self.hit_timer = 0
            self.hit = false
            self.animation = self.animations.idle
        end
    end
end

function Player:draw()
    self.animation:draw(self.image, self.x, self.y)
end

function Player:get_center()
    return self.x + 64 / 2, self.y + 64 / 2
end

function Player:cast()
    if self.attacking or self.hit or self.dead then
        return self.casting
    end

    self.casting = true
    self.attacking = false
    self.animation = self.animations.cast

    return self.casting
end

function Player:add_combo(combo)
    if not self.casting or self.dead then
        return
    end

    if combo == 'up' then combo = 'w' end
    if combo == 'down' then combo = 's' end
    if combo == 'right' then combo = 'd' end
    if combo == 'left' then combo = 'a' end

    self.mp = self.mp - 1

    if self.mp >= 0 then
        table.insert(self.combo, combo)
    else
        self.mp = self.max_mp
        self:on_hit(0)
    end
end

function Player:get_combo()
    local s = ''
    for _, v in ipairs(self.combo) do
        s = s .. v
    end

    return s
end

function Player:attack()
    if not self.attacking and #self.combo > 0 and not self.hit and not self.dead then
        self.casting = false
        self.attacking = true
        self.animation = self.animations.attack
        self.animation:gotoFrame(1)
        self.attack_timer = 0

        self.combo = {}

        return true
    end

    return false
end

function Player:on_hit(damage)
    if self.dead then
        return false
    end

    damage = damage or 0

    self.casting = false
    self.combo = {}

    self.attacking = false
    self.attack_timer = 0

    self.hp = self.hp - damage
    if self.hp <= 0 then
        Signal.emit('sounds-dead')
        self:on_dead()
        self.hp = 0
    else
        Signal.emit('sounds-hurt')
        self.hit = true
        self.hit_timer = 0
        self.animation = self.animations.hit
    end

    Signal.emit('on-player-hit', self.type)

    return true
end

function Player:on_dead()
    self.dead = true
    self.animation = self.animations.dead
end

return Player
