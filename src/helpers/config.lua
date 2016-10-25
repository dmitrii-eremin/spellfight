config = {
    keys = {        
    }
}

function config:get_keys(name)
    assert(self.keys[name])
    return self.keys[name]
end

function config:is_key_in(key, name)
    assert(self.keys[name])

    for _, k in ipairs(self.keys[name]) do
        if k == key then
            return true
        end
    end

    return false
end
