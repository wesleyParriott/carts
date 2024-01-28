# Cookie Crumbler
_A small arkanoid clone where you help a cow try and get home_

## Goal

I spend an embarassing amount of my time playing around splore and awhile back a lot of people were putting out
brick-break clones. There's a moment in brick-break where you have one brick left and you spend a lot of time trying to
get the last brick. I wanted to make a brick-break/arkanoid like game where you wouldn't have to deal with that
frustrating last-brick moment. 

## My Solutions 

I tried to solve the goal two ways: ball direction based on where it hit the paddle and creating a explosion that moves
across the screen taking 1 hit off of every cookie hit. 

### Ball Direction Based on where it Hit the Paddle

In arkanoid your ball will go in different directions based on where you hit paddle. Meaning, if you hit the right most
of the paddle the ball would go more right than if you hit the paddle just right of the center. This is done by just
lerping -1 to 1 based on where the ball is on the paddle. 

### Explosion that Moves Across the Screen

When the ball is in play you can press the "x" button (or whatever you button you have set) to explode a jug. The
explosion creates a big circle that grows larger and takes adds a life-point to every cookie it passes through. This is
just circle-vs-rectangle collision detection. The way I made sure it only hit once was to add the hit cookie to an array
and check if the collided rectangle was in that array.

## Bugs 

*There's still some weird stuff with the way collison works on the paddle.* I should just do collision the same way I do
the bricks. 

*Sometimes the score goes negitive.* I don't know if I solved this one or not. But the problem is that the numbers
pico-8 uses aren't quite as large as I originally thought. 

## Feedback

Let me know what you think! What would you do different? Does the paddle feel okay? Do you feel okay? 

If you would do something different you should make your own >:D

## Thanks

I hope you have a good day and night
