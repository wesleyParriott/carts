## Boxmoover 

A cute little game about a cow helping you move.

## Learned things

We loaded levels via reading each tile of the map, getting which sprite it was,
and creating an entity based on that. 
While the math on loading levels via the map was a little odd at first.
It lead to a really easy ways to create levels via the pico8 level editor.
The downside is that it makes it hard to reload the lvls with the same code.
Because levels loaded at the change between levels instead of at the start of the game
the map data would change until the game was restarted. 
Not being able to read the map data after a level change meant that we couldn't reload previous levels.
What would of been better would have been to save the inital map state in _init. 
Then, create levels based on that information.
Essentially only ever using spr() and not map()

This is our first time using the map editor in Pico-8.
It's fun but a little limited.
When cutting a set of sprites in the map editor you have to use the stamp tool to paste.
The pan tool will tell you what the x and y is of the upper left corner. 
We want to know more shortcuts and tricks in the map editor. 

## To anyone reading

Thanks for reading and hopefully playing :)
If you have any suggestions at feel free to let me know. Especially map editor tricks and tips!
