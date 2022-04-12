do
    Shape = {}
    Shape.__index = Shape
end

function Shape:new(checker, callback)
    local v = {checker = checker, callback = callback}
    setmetatable(v, self)
    return v
end

function Shape:check(sumOfAngles, angles, sides,data)
    if self.checker(sumOfAngles, angles, sides,data) then
        self.callback()
        return true
    end
    return false
end

