do
    Side = {}
    Side.__index = Side
end

function Side:new(start)
    local v = {start = start, en = start}
    setmetatable(v, self)
    return v
end

function Side:changeEnd(other)
    self.en = other
end

function Side:length()
    return self:getVector():length()
end

function Side:getVector()
    return VectorSubtract(self.en, self.start)
end