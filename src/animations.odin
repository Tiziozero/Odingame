package src

import rl "vendor:raylib"
// adjust later
EntityState :: enum {
    Idle,
    Running,
    Attacking,
}

TextureMapID :: enum {
    Samuri,
    Ranger,
}

SS_Animation_Data :: struct {
    row: int,
    length: int,
}
SpriteSheet :: struct {
    texture: rl.Texture2D,
    animation_info: map[EntityState]SS_Animation_Data,
    sprite_w: int,
    sprite_h: int,
    rows: int,
    cols: int,
}
