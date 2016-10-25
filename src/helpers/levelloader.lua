local LevelLoader = Class('LevelLoader')

--[[
WARTIN
ULIVIN
PHARIS
QILELA
WADOMA
BREERA
KORISY
XHIALE
TANCHI
ENESTA
HBAEND
INIOEM
YLIALA
QEDINA
CIRIDE
QULTUL
FIGUSH
MADICA
ONAGAN
WIEYAL
NTHANJ
COSSCR
UGIRIS
SARENS
ULDARY
HORALA
WETORN
ZAMITA
USTTEN
]]

LevelLoader.static.levels = {
    { name = 'debug-0', password = 'DEBUG0' },
    { name = 'debug-1', password = 'DEBUG1' },

    { name = '0-1', password = 'LYATRI' },

    { name = '1-1', password = 'DILILA' },
}

LevelLoader.static.first_level = '0-1'

function LevelLoader:initialize(folder)
    self.folder = folder or 'assets/levels/'
end

function LevelLoader:load(level)
    local map = STI(string.format('%s%s.lua', self.folder, level), {'bump'})
    map.backgroundcolor = map.backgroundcolor or {0, 0, 0}

    local objects = {}
    local world = Bump.newWorld()
    map:bump_init(world)

    local function add(object)
        table.insert(objects, object)
        world:add(object, object.position.x, object.position.y,
                  object.size.x, object.size.y)
        return object
    end

    local objects_layer = map:addCustomLayer('[INNER] Objects Layer')
    objects_layer.objects = objects

    function objects_layer:update(dt)
        for _, object in ipairs(self.objects) do
            object:update(dt, world)
        end

        for i = #self.objects, 1, -1 do
            local o = self.objects[i]
            if o.position.y > map.height * TILE_HEIGHT then
                if not o.isInstanceOf or not o:isInstanceOf(Player) then
                    table.remove(self.objects, i)
                end
            end
        end
    end

    function objects_layer:draw()
        for _, object in ipairs(self.objects) do
            object:draw()
        end
    end


    local player_layer = map:addCustomLayer('[INNER] Player Layer')
    player_layer.player = nil

    function player_layer:update(dt)

    end

    function player_layer:draw()

    end

    local objects_factory = {
        spawn = Player,

        bonus = Bonus,
        dropfloor = Dropfloor,
        movingplatform = MovingPlatform,
        areatrigger = AreaTrigger,
        signalarea = SignalArea,
        checkpoint = Checkpoint,
        spikes = Spikes,
        teleport = Teleport,
        toggle = Toggle,
        gate = Gate,
        door = Door,
        singledoor = SingleDoor,
        crusher = Crusher,
        text = ShowText,

        barnacle = Barnacle,
        ghost = Ghost,
        grassblock = GrassBlock,
        spinner = Spinner,
        snakeslime = SnakeSlime,
        bee = Bee,
        fly = Fly,
        bat = Bat,
        slime = Slime,
        snail = Snail,
        mouse = Mouse,
        snake = Snake,
        spider = Spider,
    }

    -- Add all objects
    for i, object in pairs(map.objects) do
        local args = {object.x, object.y, object.width, object.height, object.properties}

        if object.type == 'spawn' then
            player_layer.player = add(Player(unpack(args)))
        elseif #object.type > 0 then
            assert(objects_factory[object.type], object.type)
            add(objects_factory[object.type](unpack(args)))
        end
    end


    -- Sort layers by zindex
    local layers = {}
    for i, layer in ipairs(map.layers) do
        layers[i] = layer
        layer.zindex = layer.properties.zindex or i

        if layer.properties.visible == false then
            layer.visible = false
        end
    end

    layers = Lume.sort(layers, function(a, b)
        return a.zindex < b.zindex
    end)

    map.layers = layers

    objects_layer.objects = Lume.sort(objects_layer.objects, function(a, b)
        return a.zindex < b.zindex
    end)


    local level_object = {
        map = map,
        world = world,
        objects = objects,
        player = player_layer.player,
    }

    Signal.emit('level_loaded', level, level_object)
    return level_object
end

function LevelLoader.static.get_level_by_password(pass)
    for _, v in ipairs(LevelLoader.static.levels) do
        if v.password == pass then
            return v.name
        end
    end

    return nil
end

function LevelLoader.static.get_password_by_name(name)
    for _, v in ipairs(LevelLoader.static.levels) do
        if v.name == name then
            return v.password
        end
    end

    return nil
end

return LevelLoader
