screen = {
    width = 800,
    height = 600
}


angleToVector = function (angle)
    return { x = math.cos(angle), y = math.sin(angle) }
end

vectorToAngle = function (vector)
    return math.atan2(vector.y, vector.x)
end

boss = {
    status = {
        lives = 2,
        position = { x = 200, y = 300 },
        angle = 0,
        rotateSpeed = 0,
        speed = 0,
    },
    info = {
        state = nil,
        status = '',
        delay = 0,
    },
    config = {
        presentDuration = 2,
        attackDelay = 1,
        rotationForce = 1,
        maxRotationSpeed = 1,
        moveForce = 1,
        maxSpeed = 2,
        maxMoveTime = 5,
        dizzyDuration = 2
    },

    update = function (dt)
        if boss.info.state then
            boss.info.state(dt)
        end
    end,

    present = function ()
        boss.info.status = "Presenting"
        boss.info.delay = boss.config.presentDuration
        boss.info.state = boss.states.presenting
    end,

    waitToAttack = function ()
        boss.info.status = "Waiting to attack"
        boss.info.delay = boss.config.attackDelay
        boss.info.state = boss.states.waitingToAttack
    end,

    startRotation = function ()
        boss.info.status = "Getting rotation speed"
        boss.info.state = boss.states.rotatingToSpeed
    end,

    moveForward = function ()
        boss.info.status = "Moving Forward"
        boss.info.delay = boss.config.maxMoveTime
        boss.info.state = boss.states.movingForward
    end,

    getDizzy = function ()
        boss.info.status = "Dizzy"
        boss.status.speed = 0
        boss.status.rotateSpeed = 0
        boss.info.delay = boss.config.dizzyDuration
        boss.info.state = boss.states.dizzy
    end,

    states = {
        presenting = function (dt)
            boss.info.delay = boss.info.delay - dt
            if boss.info.delay <= 0 then
                boss.waitToAttack()
            end
        end,

        waitingToAttack = function (dt)
            boss.info.delay = boss.info.delay - dt
            if boss.info.delay <= 0 then
                boss.startRotation()
            end
        end,

        rotatingToSpeed = function (dt)
            boss.status.rotateSpeed = boss.status.rotateSpeed + boss.config.rotationForce * dt
            if boss.status.rotateSpeed >= boss.config.maxRotationSpeed then
                -- boss.status.angle = angle(boss.status.position.x, boss.status.position.y, mouse.x, mouse.y)
                boss.moveForward()
            end
        end,

        movingForward = function (dt)
            if boss.status.speed < boss.config.maxSpeed then
                boss.status.speed = boss.status.speed + boss.config.moveForce * dt
            end

            boss.status.position.x = boss.status.position.x + math.cos(boss.status.angle) * dt * boss.status.speed
            boss.status.position.y = boss.status.position.y + math.sin(boss.status.angle) * dt * boss.status.speed

            if boss.status.position.x < 0 or boss.status.position.y >= screen.width then
                local currentDirection = angleToVector(boss.status.angle)
                currentDirection.x = -currentDirection.x
                boss.status.angle = vectorToAngle(currentDirection)
            end

            if boss.status.position.y < 0 or boss.status.position.y >= screen.height then
                local currentDirection = angleToVector(boss.status.angle)
                currentDirection.y = -currentDirection.y
                boss.status.angle = vectorToAngle(currentDirection)
            end

            boss.info.delay = boss.info.delay - dt
            if boss.info.delay <= 0 then
                boss.getDizzy()
            end
        end,

        dizzy = function (dt)
            boss.info.delay = boss.info.delay - dt
            if boss.info.delay <= 0 then
                boss.waitToAttack()
            end
        end
    }
}

boss.present()

function love.update(dt)
   boss.update(dt)
end

function love.draw()
    love.graphics.print(boss.info.status, 100, 100)
end
