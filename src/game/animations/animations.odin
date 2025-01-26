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
    Ult,
    NormalAttack1,
    NormalAttack2,
    NormalAttack3,
    NormalAttack4,
    NormalAttack5,
    NormalAttack6,
    NormalAttack7,
    NormalAttack8,
    NormalAttackEnd1,
    NormalAttackEnd2,
    NormalAttackEnd3,
    NormalAttackEnd4,
    NormalAttackEnd5,
    NormalAttackEnd6,
    NormalAttackEnd7,
    NormalAttackEnd8,
    Skill1,
    Skill2,
    Skill3,
    SkillEnd1,
    SkillEnd2,
    SkillEnd3,
}

// honestly, idfk
AnimationTypeAttack :: struct {
    end: u32,
}

AnimationType :: union {
    AnimationTypeAttack,
}

SS_Animation_Data :: struct {
    type: AnimationType,
    row: int,
    length: int,
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
