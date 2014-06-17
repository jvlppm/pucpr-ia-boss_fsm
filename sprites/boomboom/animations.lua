local sprite = function(name)
    return love.graphics.newImage("sprites/boomboom/"..name..".png")
end

local animations = {
    presenting = {
        duration = 2,
        frames = { { image = sprite("presenting_1") }, { image = sprite("presenting_2") } }
    }
}

for k,v in pairs(animations) do
    local sum = 0

    local animation = animations[k]
    animation.duration = animation.duration or 1

    local frames = animation.frames

    for frameCount = 1, #frames do
        frames[frameCount].weight = frames[frameCount].weight or 1
        sum = sum + frames[frameCount].weight
    end

    for frameCount = 1, #frames do
        frames[frameCount].weight = frames[frameCount].weight / sum
    end
end

return animations