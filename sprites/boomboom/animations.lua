local sprite = function(name)
    return love.graphics.newImage("sprites/boomboom/"..name..".png")
end

local animations = {
    presenting = {
        duration = 2,
        frames = { { image = sprite("presenting_1") }, { image = sprite("presenting_2") } }
    },
    waiting = {
        duration = 0.3,
        frames = { { image = sprite("waiting_1") }, { image = sprite("waiting_2") } },
        resetToFrame = 1
    },
    tumbling = {
        duration = 2,
        frames = { { image = sprite("tumbling_1") }, { image = sprite("tumbling_2") } },
        resetToFrame = 1
    },
    hidden = {
        duration = 0.5,
        frames = { { image = sprite("rotating_1") }, { image = sprite("rotating_2") }, { image = sprite("rotating_3") }, { image = sprite("rotating_4") } },
        resetToFrame = 1
    },
    dying = {
        duration = 2,
        frames = { { image = sprite("dying_1"), weight = 5 }, { image = sprite("tumbling_2") }, { image = sprite("tumbling_1") } },
        resetToFrame = 3
    },
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