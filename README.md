# Breakout Project Documentation

## Part 1: Add a Powerup
Add a Powerup class to the game that spawns a powerup (images located at the bottom of the sprite sheet in the distribution code). This Powerup should spawn randomly, be it on a timer or when the Ball hits a Block enough times, and gradually descend toward the player. Once collided with the Paddle, two more Balls should spawn and behave identically to the original, including all collision and scoring points for the player. Once the player wins and proceeds to the VictoryState for their current level, the Balls should reset so that there is only one active again.

### Implementation
1. Created a powerup class with:

        function Powerup:init()
        function Powerup:collides(target)        
        function Powerup:update(dt)        
        function Powerup:render()

2. Added GeneratePowerup in Util

        function GeneratePowerup(atlas)

3. Made changes to the PlayState
    
    1. Initialize Powerup
    2. Added a timer
    3. Player collecting Powerup
    4. Spawn two balls
    5. Added updation and rendering codes for Powerup and balls


## Part 2: Change Paddle Size
Grow and shrink the Paddle such that it’s no longer just one fixed size forever. In particular, the Paddle should shrink if the player loses a heart (but no smaller of course than the smallest paddle size) and should grow if the player exceeds a certain amount of score (but no larger than the largest Paddle). This may not make the game completely balanced once the Paddle is sufficiently large, but it will be a great way to get comfortable interacting with Quads and all of the tables we have allocated for them in main.lua!

### Implementation

1. Added width dependency on size in Paddle:update(dt) and rearranged the code to allow variable dependency

        self.width = self.size * 32

2. Added logic to Increase Paddle Size
3. Added logic to Decrease Paddle Size

## Part 3: Add A Locked Brick
Add a locked Brick (located in the sprite sheet) to the level spawning, as well as a key powerup (also in the sprite sheet). The locked Brick should not be breakable by the ball normally, unless they of course have the key Powerup! The key Powerup should spawn randomly just like the Ball Powerup and descend toward the bottom of the screen just the same, where the Paddle has the chance to collide with it and pick it up. You’ll need to take a closer look at the LevelMaker class to see how we could implement the locked Brick into the level generation. Not every level needs to have locked Bricks; just include them occasionally! Perhaps make them worth a lot more points as well in order to compel their design. Note that this feature will require changes to several parts of the code, including even splitting up the sprite sheet into Bricks!

### Implementation

1. Added isLocked flag to distinguish between the lock brick and non lock brick and wrapped the entire collision logic in brick:hit()
2. Changed the GenerateQuadsBricks(atlas) function to have the locked brick as the last brick in the table (at number 22)
3. Changed the GeneratePowerup(atlas) function to have create quad for lock powerup
4. Added the Lock Brick in the LevelMaker class
5. Made changes in Powerup class to accomodate two types for powerups (one is the spawning of extra balls, the other is the key for the locked brick). Changes made to these functions:
        
        Powerup:init()
        Powerup:collides(target)
        Powerup:render()

6. Changes in PlayState
    1. Added a timer for lock powerup in PlayState:init()
    2. Added collision and updation in PlayState:update(dt)
    3. Rendering based on type in PlayState:render()

7. Changes made in the brick class for everything to come together
    1. isLocked and breakable flags in Brick:init()
    2. Wrapped original code in an if condition, and a separate code for lock brick in else part, in Brick:hit()
    3. breakable flag set to true when powerup is collected in Brick:update(dt)


Refer to my [documentation on Medium](https://ayzah-gardezi.medium.com/gd50s-breakout-project-documentation-my-implementation-0618ee3f3675) for more information about the implementation.

Click [here](https://youtu.be/R0H3F40hOhM) to watch demo.
