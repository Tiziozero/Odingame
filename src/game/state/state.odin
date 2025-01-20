package state

import rl "vendor:raylib"
import "../animations"
import "../entity"

Player :: struct {
    using entity.Entity,
}
State :: struct {
    player: ^Player,
    textures: map[animations.TextureMapID]animations.SpriteSheet,
    entities: map[int]^entity.Entity,
    quit: bool,
}
