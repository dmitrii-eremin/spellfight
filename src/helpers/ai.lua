local AI = Class('AI')

AI.static.plans = {}
table.insert(AI.static.plans, { keys = {'s', 'a', 'd', 'w', 'w', 'w', 'a', 's', 'd', 's'}, p = 3 / 32 })
table.insert(AI.static.plans, { keys = {'d', 'w', 's', 'a', 'd', 'w', 'a', 's'}, p = 4 / 32 })
table.insert(AI.static.plans, { keys = {'w', 's', 'w', 's', 'a', 's', 'w'}, p = 7 / 32 })
table.insert(AI.static.plans, { keys = {'a', 'a', 'd', 's'}, p = 22 / 32 })
table.insert(AI.static.plans, { keys = {'d', 'd', 'd'}, p = 32 / 32 })


function AI:initialize()
    self.plan = {}

    self.cast_time = {0.2, 0.4}
    self.casting = nil

    self.time_to_attack = false

    Signal.register('on-player-hit', function(t)
        if t ~= 'wizard' then
            self.plan = {}
            self.casting = nil
            self.time_to_attack = false
        end
    end)
end

function AI:update(dt)
    if self.casting then
        self.casting = self.casting - dt
        if self.casting <= 0 then
            self.casting = nil
        end
    end
end

function AI:is_plan_ready()
    return #self.plan > 0
end

function AI:attack(player, skills)
    if not self.time_to_attack then return end
    self.time_to_attack = false

    local combo = player:get_combo()
    local SkillCtor = Recipes[combo]

    if player:attack() then
        if not SkillCtor then
            player:on_hit(0)
        else
            local x, y = player:get_center()
            y = y - 16
            if index == 2 then
                x = x - 32
            end

            local skill = SkillCtor(x, y, -1)

            table.insert(skills, skill)
        end
    end
end

function AI:generate_new_plan()
    local chance = love.math.random()
    for k, v in ipairs(AI.static.plans) do
        if chance < v.p then
            self.plan = {}
            for _, key in ipairs(v.keys) do
                table.insert(self.plan, key)
            end
            break
        end
    end
    self.time_to_attack = false
end

function AI:cast(player, arrows)
    if not self.casting then
        Signal.emit('sounds-cast', 2)
        if player:cast() then
            local key = self.plan[1]
            table.remove(self.plan, 1)

            if #self.plan <= 0 then
                self.time_to_attack = true
            end

            player:add_combo(key)

            self.casting = love.math.random(unpack(self.cast_time))

            local x, y = player:get_center()
            y = y - 64
            arrows:add(key, 2, x, y)
        end
    end
end

return AI
