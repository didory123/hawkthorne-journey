local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return {
    name = 'duck',
    die_sound = 'hippy_kill',
    height = 30,
    width = 30,
    bb_width = 25,
    bb_height = 24,
    bb_offset = {x=0, y=2},
    damage = 1,
    hp = 2,
    tokens = 1,
    tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
        { item = 'coin', v = 1, p = 0.9 },
        { item = 'health', v = 1, p = 1 }
    },
    animations = {
        dying = {
            right = {'once', {'1,8'}, 1},
            left = {'once', {'1,7'}, 1}
        },
        default = {
            right = {'loop', {'1-4,2'}, 0.3},
            left = {'loop', {'1-4,1'}, 0.3}
        },
        attack = {
            right = {'loop', {'1-4,4'}, 0.1},
            left = {'loop', {'1-4,3'}, 0.1}
        }
    },
    update = function( dt, enemy, player )
        if enemy.state == 'attack' then return end

        if player.position.y + player.height - 5 <= enemy.position.y + enemy.props.height
           and math.abs(enemy.position.x - player.position.x) < 200 then
            enemy.state = 'attack' 
            enemy.direction = 'right'
            if enemy.position.x > player.position.x then
                enemy.direction = 'left'
            end
        else  
        -- if neither continue to wait
            enemy.state = 'default'
        end

        if math.abs(enemy.position.x - player.position.x) < 2 then
            -- stay put if very close to player
        elseif enemy.direction == 'left' and enemy.state == 'attack' then
            -- move to the left 
            enemy.position.x = enemy.position.x - (75 * dt)
        elseif enemy.direction == 'right' and enemy.state == 'attack' then
            -- move to the right
            enemy.position.x = enemy.position.x + (75 * dt)
        else 
            -- otherwise stay still
        end
    end
}
