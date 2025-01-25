package entity

import game "../game_common"
import "../animations"

import rl "vendor:raylib"
Item :: struct {

}

Entity :: struct {
    // entity position
    // center of entity
    pos: rl.Vector2,
    velocity: rl.Vector2,
    speed: f32,
    // body of entity to take damage
    body: rl.Rectangle,


    // attack animation after hittin (when e.attacking is false)
    // to keep animation goin
    in_attack_animation: bool,
    // flag to determinate when entity is attacking
    to_deal_damage: bool,
    // for chaining attacks to change them
    attack_index: int,
    // attack
    atkpts: f32,
    defpts: f32,
    // attack flag -> in attacking state
    attacking: bool,


    // entity state
    state: game.EntityState,
    previous_state: game.EntityState,
    hp: f32,

    // animations
    // for render
    direction: game.EntityDirection,
    draw_rect: rl.Rectangle,
    source_rect: rl.Rectangle,
    frame_time: f32,
    items: []Item,
}

Entity_Data :: struct {
    attacks: []Attack_Data,
    texture_map_id: animations.TextureMapID,
    attack_speed_slow_down: f32,
    sprite_sheet: animations.SpriteSheet,
}
Attack_Data :: struct {
    attack_range: int,
    /* "frame" ( for reference ) at which attack ends and
    entity is no longer in attack */
    attack_time: int, 
}
