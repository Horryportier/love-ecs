# love-ecs
> ecs system build on top of love2d framework 
---------- 
# Features
- entities
- commponets 
- systems 
- queries - can quarry for entites with and without components
----------
# Usage

SEE:
- [example/minimal](https://github.com/Horryportier/love-ecs/blob/main/examples/minimal/main.lua)
- [example/shapes](https://github.com/Horryportier/love-ecs/blob/main/examples/shapes/main.lua)
----------
# Current Issues
Queries use one 64 bitmask for speed meaning there can only be as mutch commponents 64 integer can hold.
Which can countered by high level types ex. shape which can be circle|rect|arc| ect.

# Plans for future
- Events
- Resources
- chaning system
- conditional systems
- system on timer


#### Contribution
feel free to give idea and discust to what should be added. 
