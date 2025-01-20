package src

import rl "vendor:raylib"
import game "../game_common"
// adjust later

TextureMapID :: enum {
    Samuri,
    Ranger,
}

SS_Animation_Data :: struct {
    row: int,
    length: int,
    can_interrupt: bool,
    can_move: bool,
    is_attack: bool,
    attack_end: int,
}
SpriteSheet :: struct {
    texture: rl.Texture2D,
    animation_info: map[game.EntityState]SS_Animation_Data,
    sprite_w: int,
    sprite_h: int,
    rows: int,
    cols: int,
}
