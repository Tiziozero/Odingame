package entity

import game "../game_common"
import "../animations"

import rl "vendor:raylib"

Entity :: struct {
    // entity position
    // center of entity
    pos: rl.Vector2,
    velocity: rl.Vector2,
    speed: f32,
    // body of entity to take damage
    body: rl.Rectangle,

    // attack
    atkpts: f32,
    defpts: f32,
    // attack flag -> in attacking state
    attacking: bool,
    // attack animation after hittin (when e.attacking is false)
    // to keep animation goin
    in_attack_animation: bool,

    attack_speed_slow_down: f32,
    // flag to determinate when entity is attacking
    to_deal_damage: bool,
    // for chaining attacks to change them
    attack_index: int,

    attack_range: int,

    // entity state
    state: game.EntityState,
    previous_state: game.EntityState,
    in_dialoge: bool,
    hp: f32,
    // animations
    // for render
    texture_map_id: animations.TextureMapID,
    direction: game.EntityDirection,
    draw_rect: rl.Rectangle,
    source_rect: rl.Rectangle,
    frame_time: f32,
}
