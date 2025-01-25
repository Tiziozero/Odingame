package game

import game "./"
import "core:fmt"
import "core:math"
import "core:mem"
import "core:time"
import "entity"
import "animations"
import "state"
import "game_common"

import rl "vendor:raylib"


FPS :: 10

damage_entity :: proc(e: ^entity.Entity, dmg: f32) {
    fmt.println("Damagin entity:", e)
    fmt.println("\tBefore:", e.hp)
    d := dmg - e.defpts
    e.hp -= d
    fmt.println("\tAfter :", e.hp)
}
get_attack_damage :: proc(e: ^entity.Entity) -> f32 {
    
    return e.atkpts;
}
entity_attack :: proc(e: ^entity.Entity) {
    if !e.attacking {
        e.state = .Attacking;

        // reset  animations
        e.attacking = true
        e.frame_time = 0;
        e.in_attack_animation = true
        fmt.println(e, " is Attacking")
    } else {
        fmt.println(e, " is already attacking")
    }

}
entity_get_attack_end ::  proc(s: ^state.State, e: ^entity.Entity) -> bool {


    return false
}
entity_attack_entities :: proc(s: ^state.State, e: ^entity.Entity) {
    for _, ent in s.entities {
        if ent == e {
            continue
        }
        d := rl.Vector2{
            e.pos.x- ent.pos.x,
            e.pos.y- ent.pos.y,
        }
        if math.sqrt(d.x*d.x+d.y*d.y) < f32(e.attack_range) {
            fmt.println("entity.Entity attacking",
                e.pos, ent.pos,
                e.pos.x- ent.pos.x,
                e.pos.y- ent.pos.y,
                d, math.sqrt(d.x*d.x+d.y*d.y), e.attack_range)
            damage_entity(ent, get_attack_damage(e))
        }
    }
}

// TODO: implement with proper handling
state_add_texture :: proc(s: ^state.State, path: cstring, id: animations.TextureMapID) {
    // t_ := rl.LoadTexture(path)
    // s.textures[id] = t_
}
free_state :: proc(s: ^state.State) {
    for id, ss in s.textures {
        fmt.println("Freed texture:", id);
        rl.UnloadTexture(ss.texture);
    }

    // free maps and arrays
    for id, ai in s.textures {
        fmt.println("Freed texture:", id);
        delete(ai.animation_info)
    }
    delete(s.textures)
    delete(s.entities)
}
handle_events :: proc(s: ^state.State) {
    player := s.player
    k := rl.GetKeyPressed()
    using rl.KeyboardKey;
    v: rl.Vector2
    if rl.IsKeyDown(W) {
        v.y -= 1
    }
    if rl.IsKeyDown(S) {
        v.y  += 1
    }
    if rl.IsKeyDown(A) {
        v.x  -= 1
    }
    if rl.IsKeyDown(D) {
        v.x += 1
    }

    v = rl.Vector2Normalize(v)
    player.velocity = v * player.speed

    for k != rl.KeyboardKey.KEY_NULL {
        #partial switch k {
        case rl.KeyboardKey.Q: s.quit = true
        case rl.KeyboardKey.L: {
            entity_attack(player)
        }
        case : {} // default case
        }
        k = rl.GetKeyPressed()
    }
}

update :: proc(s: ^state.State, dt: f32) {
    for _, e in s.entities {
        //first set state
        moving := false
        attacking := false
        dialoge := false
        move_scaler : f32 = 1.0
        if e.velocity.x != 0 || e.velocity.y != 0 {
            moving = true
        }
        if e.attacking {
            attacking = true
        }
        if !moving && !attacking && !dialoge {
            e.state = .Idle
        }
        if moving &&  !dialoge {
            e.state = .Running
        }
        if attacking {
            e.state = .Attacking
        }
        if attacking && moving {
            move_scaler *= 0.3
        }

        e.pos += e.velocity * dt * move_scaler

        // e.pos.x - e.draw_rect.width / 2,
        // body center 2 thirds down the texture
        // e.pos.y - e.draw_rect.height / 3 * 2,
        e.body.x, e.body.y = e.pos.x - e.body.width / 2, e.pos.y - e.body.height / 2
        if e.velocity.y != 0 {
            if e.velocity.y > 0 {
                e.direction = game_common.EntityDirection.Down
            } else {
                e.direction = game_common.EntityDirection.Up
            }
        }
        if e.velocity.x != 0 {
            if e.velocity.x > 0 {
                e.direction = game_common.EntityDirection.Right
            } else {
                e.direction = game_common.EntityDirection.Left
            }
        }
        // update entity frames
        e.frame_time += dt * FPS
        // check if attack is finished
        if entity_get_attack_end(s, e) {
            e.attacking = false
        }

        if e.to_deal_damage {
            // attack entities in range
            entity_attack_entities(s, e)
            e.to_deal_damage = false
        }



        draw_update_entity_animation(s, e, dt)

        e.velocity = {0, 0}
    }
}

draw_update_entity_animation :: proc(s: ^state.State, e: ^entity.Entity, dt: f32) {
    if e.previous_state != e.state {
        e.previous_state = e.state
        e.frame_time = 0
    }
    frames : f32= f32(s.textures[.Ranger].animation_info[e.state].length)
    ss_row : f32= f32(s.textures[.Ranger].animation_info[e.state].row)
    img_width : f32 = f32(s.textures[.Ranger].sprite_w)
    img_height : f32 = f32(s.textures[.Ranger].sprite_h)
    // fmt.println(frames, ss_row, img_width, img_height)
    // fmt.println(math.floor(e.frame_time), math.floor(frames), math.floor(e.frame_time) >= math.floor(frames), e.frame_time)

    // frames - 1 to have it within bounds
    if math.floor(e.frame_time) >= math.floor(frames - 1) {
        // fmt.println("over frames", e.frame_time, frames)
        if e.state == .Attacking {
            fmt.println("over frames (in attack state), setting in_attack_animation to false", e.frame_time, frames)
            e.in_attack_animation = false
        }
        e.frame_time -= frames - 1
    }
    x_index := math.floor(e.frame_time) * img_width
    y_index := math.floor(ss_row) * img_height
    i := 1
    if e.direction == .Left || e.direction == .Up {
        x_index += img_width
        i = -1
    }
    e.source_rect.x = x_index
    e.source_rect.y = y_index
    e.source_rect.width = img_width * f32(i)


    // center first and then addd offset from 
    // offsets are relative to center position
    datajson_x_offset := 0;
    e.draw_rect.x = e.pos.x - e.draw_rect.width / 2;
    datajson_y_offset := - e.draw_rect.height / 2 + e.body.height / 2;
    e.draw_rect.y = e.pos.y - e.draw_rect.height / 2 + datajson_y_offset;
}

sort_entities :: proc(entities: [dynamic]^entity.Entity) {
    changed := true;
    for changed {
        changed = false;
        for i in 1..<len(entities) {
            p := entities[i-1].pos.y
            n := entities[i].pos.y
            if p > n {
                t := entities[i-1]
                entities[i-1] = entities[i]
                entities[i] = t
                changed = true;
            }

        }
    }
}

draw :: proc(s: ^state.State) {
    player := s.player

    entities: [dynamic]^entity.Entity
    for _, e in s.entities {
        append(&entities, e)
    }
    sort_entities(entities)
    rl.BeginDrawing();

    rl.ClearBackground(rl.BLACK);
    // Debug
    for e in entities {
        rl.DrawRectangleRec(e.draw_rect, {255,255,255,255});
        rl.DrawRectangleRec(e.body, rl.Color{255,112, 10, 58});        // rl.DrawCircleV(e.pos, 2, rl.WHITE);
        rl.DrawCircleV(e.pos, f32(e.attack_range), rl.Color{0,112, 198, 58});        // rl.DrawCircleV(e.pos, 2, rl.WHITE);
    }
    for e in entities {
        rl.DrawTextureRec(s.textures[e.texture_map_id].texture, e.source_rect,
            {e.draw_rect.x, e.draw_rect.y}, {255,255,255,255});
    }
    for e in entities {
        rl.DrawCircleV(e.pos, 4, rl.Color{255,255, 255, 255});
    }
    delete(entities)

    rl.EndDrawing();
}
main_1 :: proc() {
    fmt.println("Start main")

    // init raylib
    rl.InitWindow(800, 500, "Hello from Odin!!!");
    rl.SetTargetFPS(60);

    // init state
    s := state.State{}

    t_ := rl.LoadTexture("assets/elemental_ranger/Elementals_leaf_ranger_288x128_SpriteSheet.png")

    ss := animations.SpriteSheet{}
    ss.texture = t_
    ss.sprite_w = 288
    ss.sprite_h = 128
    ss.rows = 17
    ss.cols = 22

    a := animations.SS_Animation_Data {
        row = 0, length = 12,
    }
    ss.animation_info[.Idle] = a
    b := animations.SS_Animation_Data {
        row = 1, length = 10,
    }
    ss.animation_info[.Running] = b

    c := animations.SS_Animation_Data {
        // attack ends at frame 12
        row = 13, length = 17,
    }
    ss.animation_info[.Attacking] = c
    s.textures[.Ranger] = ss
    // fmt.println(s)
    p := state.Player{
        // position
        pos={200,300},
        body={width=40, height=48},
        speed=200,
        // render
        draw_rect={width=f32(ss.sprite_w), height=f32(ss.sprite_h)},
        // to reflect just use negative width and height
        source_rect={width=f32(ss.sprite_w), height=f32(ss.sprite_h), x=0, y=0},
        
        // state
        state = .Idle,

        // attacking
        attacking = false,
        attack_speed_slow_down = 0.25,
        attack_index = 0,
        attack_range = 48,
        atkpts = 60,
        defpts = 10,
        hp = 300,

        //animation
        texture_map_id = .Ranger,
    }
    test_entity := entity.Entity{
        // position
        pos={400,300},
        body={width=40, height=48},
        speed=200,
        // render
        draw_rect={width=f32(ss.sprite_w), height=f32(ss.sprite_h)},
        // to reflect just use negative width and height
        source_rect={width=f32(ss.sprite_w), height=f32(ss.sprite_h), x=0, y=0},
        
        // state
        state = .Idle,

        // attacking
        attacking = false,
        attack_speed_slow_down = 0.25,
        attack_index = 0,
        attack_range = 48,
        atkpts = 60,
        defpts = 10,
        hp = 300,
        texture_map_id = .Ranger,
    }

    s.player = &p
    s.entities[0] = &p
    // s.entities[1] = &test_entity
    // state_add_texture(&s, "assets/samurai/idle.png", .PlayerIdle)
    // state_add_texture(&s, "assets/samurai/run.png", .PlayerRunning)
    // state_add_texture(&s, "assets/samurai/attack.png", .PlayerAttack)


    for !rl.WindowShouldClose() && !s.quit {
        // fmt.println(p)
        dt := rl.GetFrameTime()

        handle_events(&s)
        update(&s, dt)
        draw(&s);
    }

    // free memory
    free_state(&s)
    rl.CloseWindow();

    fmt.println("End main");
}
