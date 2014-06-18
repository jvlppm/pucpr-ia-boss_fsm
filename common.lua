local common = {}

function common.angleToVector (angle)
    return { x = math.cos(angle), y = math.sin(angle) }
end

function common.vectorToAngle (vector)
    return math.atan2(vector.y, vector.x)
end

function common.vectorLength (vector)
    return math.sqrt(vector.x * vector.x + vector.y * vector.y)
end

function common.angle (x1, y1, x2, y2)
    return common.vectorToAngle(common.normalize ({ x = x2 - x1, y = y2 - y1 }))
end

function common.normalize (vector)
    local length = common.vectorLength(vector)
    return { x = vector.x / length, y = vector.y / length }
end

return common
