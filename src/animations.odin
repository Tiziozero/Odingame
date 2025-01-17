package src

import rl "vendor:raylib"

TextureMapID :: enum {
    PlayerIdle,
    PlayerRunning,
    PlayerAttack,
}

SS_Animation_Data :: struct {
    row: int,
    length: int,
}
SpriteSheet :: struct {
    texture: rl.Texture2D,
    sprite_w: int,
    sprite_h: int,
    rows: int,
    cols: int,
}
