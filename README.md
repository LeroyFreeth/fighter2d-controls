# fighter2d-controls
Controls and state machine for a 2d fighter in which characters can freely choose their facing direction.

## In active development

Project is still very bare bones. Basic setup for the inputs are done.
Controls:

|  Button |  Action | 
|---|---|
| A  | Left/Right | 
| D  | Left/Right |
| S | Down |
| W | UP |
| Space | Action A |
| G | Action B |
| H | Action C |
| J | Action D |

Only a few moves are setup:

Walk foward - A/D depending on facing direction
Walk backward - A/D depending on facing direction. Will turn around into walk forward after x duration of keep walking backward
Dash forward - A + A (hold)/D + D (hold) depending on facing direction. If not facing direction, hold is required.
Dash backward - A + A (tap) /D + D (tap) depending on facing direction. Cannot backdash in same direction as facing. Will dash backward without turning around.

