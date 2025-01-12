--[[
Powerup class for powerup sprite to appear and go down the screen after 
certain time has elapsed.
]]

Powerup = Class{}

function Powerup:init(powerupType)
    self.width = 16
    self.height = 16
    self.x = math.random(0, VIRTUAL_WIDTH - self.width)
    self.y = -16
    self.dy = 0
    self.collected = false  -- will be rendered until it is collected
    self.soundPlayed = false
    self.balls = {}
    self.playerContainer = nil -- might not need this
    self.ballsSkin = nil
    self.type = powerupType
end

function Powerup:collides(target)
    if self.y + self.height < target.y or self.y > target.y + target.height then
        return false
    end
    
    if self.x > target.x + target.width or self.x + self.width < target.x then
        return false
    end

    -- sound was playing twice due to frames per second processing so I put a flag
    if not self.soundPlayed then 
        gSounds['confirm']:play()
        self.soundPlayed = true
    end
    if self.type == 1 then
        for i = 1, 2 do
            self.balls[i] = Ball(self.ballsSkin)
            self.balls[i]:reset()
        end
    end

    self.collected = true -- will not be rendered when collected

    return true
end

function Powerup:update(dt)
    self.y = self.y + self.dy * dt
end

function Powerup:render()
    if (not self.collected) then
        love.graphics.draw(gTextures['main'], gFrames['powerup'][self.type], self.x, self.y)
    end
end
