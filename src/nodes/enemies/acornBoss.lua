local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local Projectile = require 'nodes/projectile'
local sound = require 'vendor/TEsound'
local utils = require 'utils'

local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'

return {
    name = 'acornBoss',
    attack_sound = 'acorn_growl',
    hurt_sound = 'acorn_crush',
    height = 40,
    width = 40,
    damage = 2,
    jumpkill = false,
    player_rebound = 100,
    bb_width = 40,
    bb_height = 40,
    hp = 30,
    tokens = 15,
    tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
        { item = 'coin', v = 1, p = 0.9 },
        { item = 'health', v = 1, p = 1 }
    },
    animations = {
        jump = {
            right = {'loop', {'7-6,1'}, 1},
            left = {'loop', {'7-6,2'}, 1}
        },
        dying = {
            right = {'once', {'1,1'}, 0.25},
            left = {'once', {'1,2'}, 0.25}
        },
        default = {
            right = {'loop', {'4-5,1'}, 0.25},
            left = {'loop', {'4-5,2'}, 0.25}
        },
        hurt = {
            right = {'loop', {'4-5,1'}, 0.25},
            left = {'loop', {'4-5,2'}, 0.25}
        },
        ragehurt = {
            right = {'loop', {'1-2,1'}, 0.25},
            left = {'loop', {'1-2,2'}, 0.25}
        },
        rage = {
            right = {'loop', {'9-10,1'}, 0.25},
            left = {'loop', {'9-10,2'}, 0.25}
        },
    },
    enter = function( enemy )
        enemy.direction = math.random(2) == 1 and 'left' or 'right'
    end,

    hurt = function( enemy )
        if enemy.state == 'rage' then 
            enemy.state = 'ragehurt'
        end
    end,

    draw = function( enemy )
        fonts.set( 'small' )
    
    love.graphics.setStencil( )

        local energy = love.graphics.newImage('images/enemies/bossHud/energy.png')
        local bossChevron = love.graphics.newImage('images/enemies/bossHud/bossChevron.png')
        local bossPic = love.graphics.newImage('images/enemies/bossHud/turkeyBoss.png')

        energy:setFilter('nearest', 'nearest')
        bossChevron:setFilter('nearest', 'nearest')
        bossPic:setFilter('nearest', 'nearest')

        x, y = camera.x + window.width - 130 , camera.y + 10


        love.graphics.setColor( 255, 255, 255, 255 )
        love.graphics.draw( bossChevron, x , y )
        love.graphics.draw( bossPic, x + 69, y + 10 )

        love.graphics.setColor( 0, 0, 0, 255 )
        love.graphics.printf( "ACORN", x + 15, y + 15, 52, 'center' )
        love.graphics.printf( "KING", x + 15, y + 41, 52, 'center'  )

        energy_stencil = function( x, y )
            love.graphics.rectangle( 'fill', x + 11, y + 27, 59, 9 )
        end
        love.graphics.setStencil(energy_stencil, x, y)
        local max_hp = 30
        local rate = 55/max_hp
        love.graphics.setColor(
            math.min(utils.map(enemy.hp, max_hp, max_hp / 2 + 1, 0, 255 ), 255), -- green to yellow
            math.min(utils.map(enemy.hp, max_hp / 2, 0, 255, 0), 255), -- yellow to red
            0,
            255
        )
        love.graphics.draw(energy, x + ( max_hp - enemy.hp ) * rate, y)

        love.graphics.setStencil( )
        love.graphics.setColor( 255, 255, 255, 255 )
          fonts.revert()

    end,

    update = function( dt, enemy, player )

        local rage_velocity = 1

        if enemy.position.x < player.position.x then
                enemy.direction = 'right'
        elseif enemy.position.x + enemy.props.width > player.position.x + player.width then
                enemy.direction = 'left'
        end

        enemy.last_jump = enemy.last_jump + dt
        if math.abs(enemy.position.x - player.position.x) < 100 then
            if enemy.last_jump > 1 then
                enemy.state = 'jump'
                enemy.last_jump = 0
                enemy.velocity.y = -500
                Timer.add(.5, function()
                 enemy.state = 'default'
            end)
        end
        end

        if math.abs(enemy.position.x - player.position.x) < 2 or enemy.state == 'dying' or enemy.state == 'rage' then
            -- stay put
        elseif enemy.direction == 'left' then
            enemy.position.x = enemy.position.x - (10 * dt)
        else
            enemy.position.x = enemy.position.x + (10 * dt)
        end

        if enemy.hp < 20 then
                 enemy.state = 'rage'
                 rage_velocity = 5
        end

  
        if enemy.direction == 'left' then
            enemy.velocity.x = 20 * rage_velocity
        else
            enemy.velocity.x = -20 * rage_velocity
        end

    end    
}
