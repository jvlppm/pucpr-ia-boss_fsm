local common = require "common"
local animations = require "sprites/boomboom/animations"

local boomboom = { }

function boomboom.create ()
    return {
        status = {
            lives = 2,
            position = { x = screen.width / 2, y = screen.height / 2 },
            angle = 1.12,
            rotateSpeed = 0,
            speed = 0,
        },
        info = {
            state = nil,
            status = '',
            delay = 0,
            mirror = false
        },
        config = {
            presentDuration = 2,
            attackDelay = 1,
            rotationForce = 1,
            maxRotationSpeed = 1,
            angleChangeSpeed = 2,
            moveForce = 30,
            hiddenMoveForce = 30,
            maxSpeed = 128,
            maxSpeedHidden = 256,
            maxMoveTime = 10,
            maxMoveTimeHidden = 15,
            dizzyDuration = 2,
            origin = { 0.5, 1 }
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

        hit = function (self)
            self.info.hit = true
        end,

        currentFrame = function(self)
            if not self.animations.current or self.animations.currentFrame > #self.animations.current.frames then
                return nil
            end
            return self.animations.current.frames[self.animations.currentFrame].image
        end,

        getWidth = function(self)
            local frame = self:currentFrame()
            if not frame then return 0 end
            return frame:getWidth()
        end,

        getHeight = function(self)
            local frame = self:currentFrame()
            if not frame then return 0 end
            return frame:getHeight()
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

                local scaleX = 1
                if self.info.mirror then
                    scaleX = -1
                end

                love.graphics.draw(currentAnimation.frames[frameIndex].image, position.x - self.config.origin[1] * self:getWidth(), position.y - self.config.origin[2] * self:getHeight(), 0, scaleX, 1)
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
            self:setAnimation(animations.waiting)
        end,

        startRotation = function (self)
            self.info.status = "Getting rotation speed"
            self.info.state = self.states.rotatingToSpeed
        end,

        charge = function (self)
            self.info.status = "Charging"
            self.info.delay = self.config.maxMoveTime
            self.info.state = self.states.charging
        end,

        getDizzy = function (self)
            self.info.status = "Dizzy"
            self.status.speed = 0
            self.status.rotateSpeed = 0
            self.info.delay = self.config.dizzyDuration
            self.info.state = self.states.dizzy
        end,

        startRotationHidden = function (self)
            self.info.status = "Rotating to attack in the shell"
            self.info.state = self.states.rotatingToSpeedHidden
            self:setAnimation(animations.hidden)
        end,

        chargeHidden = function (self)
            self.info.status = "Attack while in the shell"
            self.info.delay = self.config.maxMoveTimeHidden
            self.info.state = self.states.chargingHidden
            self:setAnimation(animations.hidden)
        end,

        states = {
            presenting = function (self, dt)
                if self:gotHit() then return end

                if self.animations.animationComplete then
                    self:waitToAttack()
                end
            end,

            waitingToAttack = function (self, dt)
                if self:gotHit() then return end

                self.info.delay = self.info.delay - dt
                if self.info.delay <= 0 then
                    self:startRotation()
                end
            end,

            rotatingToSpeed = function (self, dt)
                if self:gotHit() then return end

                self.status.rotateSpeed = self.status.rotateSpeed + self.config.rotationForce * dt
                if self.status.rotateSpeed >= self.config.maxRotationSpeed then
                    x, y = love.mouse.getPosition()
                    self:lookTo( { x = x, y = y } )
                    self:charge()
                end
            end,

            charging = function (self, dt)
                if self:gotHit() then return end

                if self.status.speed < self.config.maxSpeed then
                    self.status.speed = self.status.speed + self.config.moveForce * dt
                end

                x, y = love.mouse.getPosition()
                self:lookTo( { x = x, y = y }, dt )
                self:advancePosition(dt)
                self:stopOnWalls()

                self.info.delay = self.info.delay - dt
                if self.info.delay <= 0 then
                    self:getDizzy()
                end
            end,

            dizzy = function (self, dt)
                if self:gotHit() then return end

                self.info.delay = self.info.delay - dt
                if self.info.delay <= 0 then
                    self:waitToAttack()
                end
            end,

            tumbling = function (self, dt)
                self:ignoreHit()

                if self.animations.animationComplete then
                    self:startRotationHidden()
                end
            end,

            rotatingToSpeedHidden = function (self, dt)
                self:ignoreHit()

                self.status.rotateSpeed = self.status.rotateSpeed + self.config.rotationForce * dt
                if self.status.rotateSpeed >= self.config.maxRotationSpeed then
                    x, y = love.mouse.getPosition()
                    self:lookTo( { x = x, y = y } )
                    self:chargeHidden()
                end
            end,

            chargingHidden = function (self, dt)
                self:ignoreHit()

                if self.status.speed < self.config.maxSpeedHidden then
                    self.status.speed = self.status.speed + self.config.hiddenMoveForce * dt
                end

                self:advancePosition(dt)
                self:bounceOnWalls()

                self.info.delay = self.info.delay - dt
                if self.info.delay <= 0 then
                    self:getDizzy()
                end
            end,

            dying = function (self, dt)
                self:ignoreHit()
            end
        },

        gotHit = function (self)
            if not self.info.hit then
                return false
            end
            self.info.hit = false

            self.status.lives = self.status.lives - 1
            self.status.rotateSpeed = 0
            if self.status.lives >= 0 then
                self.info.status = "Hit"
                self.info.state = self.states.tumbling
                self:setAnimation(animations.tumbling)
            else
                self.info.status = "Dead"
                self.info.state = self.states.dying
                self:setAnimation(animations.dying)
            end
            return true
        end,

        ignoreHit = function(self)
            self.info.hit = false
        end,

        advancePosition = function (self, dt)
            local currentDirection = common.angleToVector(self.status.angle)
            self.status.position.x = self.status.position.x + currentDirection.x * dt * self.status.speed
            self.status.position.y = self.status.position.y + currentDirection.y * dt * self.status.speed
        end,

        bounceOnWalls = function (self)
            local currentDirection = common.angleToVector(self.status.angle)

            local xSpeed = math.abs(currentDirection.x)
            local ySpeed = math.abs(currentDirection.y)

            if self.status.position.x < 0 then
                currentDirection.x = xSpeed
                self.status.position.x = 0
            end

            if self.status.position.x >= screen.width then
                currentDirection.x = -xSpeed
                self.status.position.x = screen.width - 1
            end

            if self.status.position.y < 0 then
                currentDirection.y = ySpeed
                self.status.position.y = 0
            end

            if self.status.position.y >= screen.height then
                currentDirection.y = -ySpeed
                self.status.position.y = screen.height - 1
            end

            self.status.angle = common.vectorToAngle(currentDirection)
        end,

        stopOnWalls = function (self)
            if self.status.position.x < 0 then
                self.status.position.x = 0
                self.status.speed = 0
            end

            if self.status.position.x >= screen.width then
                self.status.position.x = screen.width - 1
                self.status.speed = 0
            end

            if self.status.position.y < 0 then
                self.status.position.y = 0
                self.status.speed = 0
            end

            if self.status.position.y >= screen.height then
                self.status.position.y = screen.height - 1
                self.status.speed = 0
            end
        end,

        lookTo = function (self, position, dt)
            local angle = common.angle( self.status.position.x, self.status.position.y, position.x, position.y )
            if not dt then
                self.status.angle = angle
            else

                local diff = angle - self.status.angle
                if diff > math.pi then
                    diff = diff - ((2*math.pi));
                elseif diff < -math.pi then
                    diff = diff + ((2*math.pi));
                end

                local direction = diff < 0 and -1 or 1

                self.status.angle = self.status.angle + dt * direction * self.config.angleChangeSpeed

                if self.status.angle > math.pi then
                    self.status.angle = self.status.angle - math.pi * 2
                end
                if self.status.angle < -math.pi then
                    self.status.angle = self.status.angle + math.pi * 2
                end
            end
        end,

        overlapping = function(self, x, y)
            local bossX = boss.status.position.x - boss.config.origin[1] * boss:getWidth()
            local bossY = boss.status.position.y - boss.config.origin[2] * boss:getHeight()

            local xHit = x >= bossX and x < bossX + boss:getWidth()
            local yHit = y >= bossY and y < bossY + boss:getHeight()

            return xHit and yHit
        end
    }
end

return boomboom