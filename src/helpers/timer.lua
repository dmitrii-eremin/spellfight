local Timer = Class('Timer')

function Timer:initialize(value)
    self.value = value or 0
    self.inversed = value and true or false
    self.direction = value and -1 or 1
end

function Timer:update(dt)
    self.value = self.value + dt * self.direction
end

function Timer:to_seconds()
    return math.floor(self.value)
end

return Timer
