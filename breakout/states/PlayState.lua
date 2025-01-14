--[[
    GD50 2018
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    ball.dx = math.random(-200, 200)
    -- give a random y velocity, but add an amount (capped) based on the level
    ball.dy = math.random(-50, -60) - math.min(100, level * 5)

    -- keep track of whether the game is paused
    self.paused = false

    -- create powerup (moving is false by default)
    powerup = Powerup(1)
    powerup.ballsSkin = ((ball.skin % 7) + 1)

    -- timer
    powerupTimer = {
        duration = math.random(5, 20), -- Time in seconds
        elapsed = 0,
        active = true
    }

    lockPowerupTimer = {
        duration = math.random(5, 20), -- Time in seconds
        elapsed = 0,
        active = true
    }

    previousScore = 500

    lockPowerup = Powerup(2)

    if lockBrick then
        lockPowerupTimer.active = true
    else
        lockPowerupTimer.active = false
    end
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('escape') then
            love.event.quit()
        end

        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['music']:resume()
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['music']:pause()
        gSounds['pause']:play()
        return
    end

    -- player input
    playerMove(dt)

    -- update positions based on velocity
    player:update(dt)
    ball:update(dt)

    paddleCollision(ball, dt)

    if powerup.collected then
        for i = 1, 2 do
            paddleCollision(powerup.balls[i], dt)
        end
    end

    -- removed the brickCollision logic from here and turned it into a function
    -- so that the powerup balls can use the same (attempt to modularize the code)
    brickCollision(ball, dt)

    if powerup.collected then
        for i = 1, 2 do
            brickCollision(powerup.balls[i], dt)
        end
    end

    -- if original ball goes below bounds, revert to serve state and decrease health
    if ball.y >= VIRTUAL_HEIGHT then
        health = health - 1
        gSounds['hurt']:play()
        -- make paddle size smaller
        if player.size > 1 then
            player.size = player.size - 1
        end

        if health == 0 then
            gStateMachine:change('game-over')
        else
            gStateMachine:change('serve', player.skin)
        end
    end


    for k, brick in pairs(bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    -- timer logic
    if powerupTimer.active then
        powerupTimer.elapsed = powerupTimer.elapsed + dt
        if powerupTimer.elapsed >= powerupTimer.duration then
            powerupTimer.active = false
            powerup.dy = 50
        end
    end

    if lockPowerupTimer.active then
        lockPowerupTimer.elapsed = lockPowerupTimer.elapsed + dt
        if lockPowerupTimer.elapsed >= lockPowerupTimer.duration then
            lockPowerupTimer.active = false
            lockPowerup.dy = 50
        end
    end

    -- player collects powerup
    if powerup:collides(player) then
        for i = 1, 2 do
            powerup.balls[i].dx = math.random(-200, 200)
            powerup.balls[i].dy = math.random(-50, -60) - math.min(100, level * 5)
        end
    end
    powerup:update(dt)
    if powerup.collected then
        for i = 1, 2 do 
            powerup.balls[i]:update(dt)
        end
    end

    if lockPowerup:collides(player) then
        lockBrickHolder.breakable = true
    end

    if lockBrick then
        lockPowerup:update(dt)
    end
end

function brickCollision(_ball, dt)
    for k, brick in pairs(bricks) do
        if brick.inPlay and _ball:collides(brick) then
            if not brick.isLocked then
                score = score + (brick.tier * 200 + brick.color * 25)
            else
                if brick.breakable then
                    score = score + 500
                end
            end
            brick:hit()

            -- if we have enough points, recover a point of health
            if score > recoverPoints then
                -- can't go above 3 health
                health = math.min(3, health + 1)

                -- multiply recover points by 2, but no more than 100000
                recoverPoints = math.min(100000, recoverPoints * 2)

                -- play recover sound effect
                gSounds['recover']:play()
            end

            if score > 2 * previousScore then
                if player.size < 4 then
                    player.size = player.size + 1
                end
                previousScore = score
            end

            if PlayState:checkVictory() then
                gStateMachine:change('victory')
            end

            -- first, reapply inverted velocity to reset our position
            _ball.x = _ball.x + -_ball.dx * dt
            _ball.y = _ball.y + -_ball.dy * dt

            -- hit from the left
            if _ball.dx > 0 then
                -- left edge
                if _ball.x + 2 < brick.x then
                    _ball.dx = -_ball.dx
                -- top edge
                elseif _ball.y + 1 < brick.y then
                    _ball.dy = -_ball.dy
                -- bottom edge
                else
                    -- bottom edge
                    _ball.dy = -_ball.dy
                end
            else
                -- right edge
                if _ball.x + 6 > brick.x + brick.width then
                    -- reset _ball position
                    _ball.dx = -_ball.dx
                elseif _ball.y + 1 < brick.y then
                    -- top edge
                    _ball.dy = -_ball.dy
                else
                    -- bottom edge
                    _ball.dy = -_ball.dy
                end
            end

            -- slightly scale the y velocity to speed up the game
            _ball.dy = _ball.dy * 1.02

            -- only collide with one brick per turn
            break
        end
    end
end

function paddleCollision(_ball, dt)
    -- bounce the ball back up if we collide with the paddle
    if _ball:collides(player) then
        -- raise _ball above paddle in case it goes below it, then reverse dy
        _ball.y = player.y - ball.height
        _ball.dy = -_ball.dy

        --
        -- tweak angle of bounce based on where it hits the paddle
        --

        -- if we hit the paddle on its left side...
        if _ball.x < player.x + (player.width / 2) and player.dx < 0 then
            -- if the player is moving left...
            if player.dx < 0 then
                _ball.dx = -math.random(30, 50 + 
                    10 * player.width / 2 - (_ball.x + 8 - player.x))
            end
        else
            -- if the player is moving right...
            if player.dx > 0 then
                _ball.dx = math.random(30, 50 + 
                    10 * (_ball.x - player.x - player.width / 2))
            end
        end
        gSounds['paddle-hit']:play()
    end
end

function PlayState:render()
    player:render()
    ball:render()

    renderBricks()
    renderScore()
    renderHealth()

    for k, brick in pairs(bricks) do
        brick:renderParticles()
    end

    -- current level text
    love.graphics.setFont(smallFont)
    love.graphics.printf('Level ' .. tostring(level),
        0, 4, VIRTUAL_WIDTH, 'center')

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(largeFont)
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
    
    powerup:render() -- rendering at the end so that it's rendered on top of everything else

    if powerup.collected then
        for i = 1, 2 do 
            powerup.balls[i]:render()
        end
    end

    if lockBrick then
        lockPowerup:render()
    end

end

function PlayState:checkVictory()
    for k, brick in pairs(bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end
