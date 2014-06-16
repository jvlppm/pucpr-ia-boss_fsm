local common = {}

function common.angleToVector (angle)
    return { x = math.cos(angle), y = math.sin(angle) }
end

function common.vectorToAngle (vector)
    return math.atan2(vector.y, vector.x)
end

return common
