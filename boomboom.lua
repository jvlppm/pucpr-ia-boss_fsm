local common = require "common"
local animations = require "sprites/boomboom/animations"

local boomboom = { }

function boomboom.create ()
    return {
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

        animations = {
            current = nil,
            currentFrame = 1,
            timeEllapsed = 0,
            animationComplete = true
        },

        update = function (self, dt)
            if self.info.state then
                self.info.state(self, dt)
            end

            self:advanceFrame(dt)
        end,

        advanceFrame = function(self, dt)
            if not self.animations.current or self.animations.currentFrame > #self.animations.current.frames then
                return
            end

            self.animations.timeEllapsed = self.animations.timeEllapsed + dt
            local animationDuration = self.animations.current.duration
            local frameDuration = animationDuration * self.animations.current.frames[self.animations.currentFrame].weight

            if self.animations.timeEllapsed >= frameDuration then
                self.animations.timeEllapsed = 0
                if self.animations.currentFrame <= #self.animations.current.frames then
                    self.animations.currentFrame = self.animations.currentFrame + 1
                end
                if self.animations.currentFrame > #self.animations.current.frames then
                    self.animations.animationComplete = true
                    self.animations.currentFrame = self.animations.current.resetToFrame or #self.animations.current.frames
                end
            end
        end,

        draw = function (self)
            local currentAnimation = self.animations.current
            if currentAnimation == nil or currentAnimation.frames == nil then
                return
            end

            if self.animations.currentFrame <= #currentAnimation.frames then
                local position = self.status.position
                local frameIndex = self.animations.currentFrame

                love.graphics.draw(currentAnimation.frames[frameIndex].image, position.x, position.y)
            end
        end,

        setAnimation = function (self, anim)
            if (self.animations.current ~= anim) then
                self.animations.current = anim
                self.animations.currentFrame = 1
                self.animations.timeEllapsed = 0
                self.animations.animationComplete = false
            end
        end,

        present = function (self)
            self.info.status = "Presenting"
            self.info.state = self.states.presenting
            self:setAnimation(animations.presenting)
        end,

        waitToAttack = function (self)
            self.info.status = "Waiting to attack"
            self.info.delay = self.config.attackDelay
            self.info.state = self.states.waitingToAttack
        end,

        startRotation = function (self)
            self.info.status = "Getting rotation speed"
            self.info.state = self.states.rotatingToSpeed
        end,

        moveForward = function (self)
            self.info.status = "Moving Forward"
            self.info.delay = self.config.maxMoveTime
            self.info.state = self.states.movingForward
        end,

        getDizzy = function (self)
            self.info.status = "Dizzy"
            self.status.speed = 0
            self.status.rotateSpeed = 0
            self.info.delay = self.config.dizzyDuration
            self.info.state = self.states.dizzy
        end,

        states = {
            presenting = function (self, dt)
                self.info.delay = self.info.delay - dt
                if self.animations.animationComplete then
                    self:waitToAttack()
                end
            end,

            waitingToAttack = function (self, dt)
                self.info.delay = self.info.delay - dt
                if self.info.delay <= 0 then
                    self:startRotation()
                end
            end,

            rotatingToSpeed = function (self, dt)
                self.status.rotateSpeed = self.status.rotateSpeed + self.config.rotationForce * dt
                if self.status.rotateSpeed >= self.config.maxRotationSpeed then
                    -- self.status.angle = angle(self.status.position.x, self.status.position.y, mouse.x, mouse.y)
                    self:moveForward()
                end
            end,

            movingForward = function (self, dt)
                if self.status.speed < self.config.maxSpeed then
                    self.status.speed = self.status.speed + self.config.moveForce * dt
                end

                self.status.position.x = self.status.position.x + math.cos(self.status.angle) * dt * self.status.speed
                self.status.position.y = self.status.position.y + math.sin(self.status.angle) * dt * self.status.speed

                if self.status.position.x < 0 or self.status.position.y >= screen.width then
                    local currentDirection = angleToVector(self.status.angle)
                    currentDirection.x = -currentDirection.x
                    self.status.angle = vectorToAngle(currentDirection)
                end

                if self.status.position.y < 0 or self.status.position.y >= screen.height then
                    local currentDirection = angleToVector(self.status.angle)
                    currentDirection.y = -currentDirection.y
                    self.status.angle = vectorToAngle(currentDirection)
                end

                self.info.delay = self.info.delay - dt
                if self.info.delay <= 0 then
                    self:getDizzy()
                end
            end,

            dizzy = function (self, dt)
                self.info.delay = self.info.delay - dt
                if self.info.delay <= 0 then
                    self:waitToAttack()
                end
            end
        }
    }
end

return boomboom