package src

import rl "vendor:raylib"
import game "../game_common"
// adjust later

TextureMapID :: enum {
    Samuri,
    Ranger,
}

AnimationIndex :: enum {
    Idle,
    Run,
    Walk,
    BaseAttack1,
    BaseAttack2,
    BaseAttack3,
    BaseAttack4,
    BaseAttack5,
    BaseAttack6,
    BaseAttack7,
    BaseAttack8,
    BaseAttack9,
}

SS_Animation_Data :: struct {
    row: int,
    length: int,
    can_interrupt: bool,
    can_move: bool,
    is_attack: bool,
    attack_end: int,
    body_x_offset: f32,
    body_y_offset: f32,
    body_width: f32,
    body_height: f32,
}
SpriteSheet :: struct {
    texture: rl.Texture2D,
    animation_info: map[AnimationIndex]SS_Animation_Data,
    sprite_w: int,
    sprite_h: int,
    rows: int,
    cols: int,
}
