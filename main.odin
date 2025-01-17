package main

import "core:fmt"
import "core:math"
import "core:mem"
import "core:time"
import "src"

import rl "vendor:raylib"
ATTACK_FRAME :: 5
img_width :: 288
img_height :: 128
FPS :: 10
EntityDirection :: enum {
    Up,
    Down,
    Left,
    Right,
}

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
    state: src.EntityState,
    previous_state: src.EntityState,
    hp: f32,
    // animations
    // for render
    texture_map_id: src.TextureMapID,
    direction: EntityDirection,
    draw_rect: rl.Rectangle,
    source_rect: rl.Rectangle,
    frame_time: f32,
}
Player :: struct {
    using Entity,
}
State :: struct {
    player: ^Player,
    textures: map[src.TextureMapID]src.SpriteSheet,
    entities: map[int]^Entity,
    quit: bool,
}

damage_entity :: proc(e: ^Entity, dmg: f32) {
    fmt.println("Damagin entity:", e)
    fmt.println("Before:", e.hp)
    d := dmg - e.defpts
    e.hp -= d
    fmt.println("After :", e.hp)
}
get_attack_damage :: proc(e: ^Entity) -> f32 {
    
    return e.atkpts;
}
entity_attack :: proc(e: ^Entity) {
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
entity_attack_entities :: proc(s: ^State, e: ^Entity) {
    for _, ent in s.entities {
        if ent == e {
            continue
        }
        d := rl.Vector2{
            e.pos.x- ent.pos.x,
            e.pos.y- ent.pos.y,
        }
        if math.sqrt(d.x*d.x+d.y*d.y) < f32(e.attack_range) {
            fmt.println("Entity attacking",
                e.pos, ent.pos,
                e.pos.x- ent.pos.x,
                e.pos.y- ent.pos.y,
                d, math.sqrt(d.x*d.x+d.y*d.y), e.attack_range)
            damage_entity(ent, get_attack_damage(e))
        }
    }
}

// TODO: implement with proper handling
state_add_texture :: proc(s: ^State, path: cstring, id: src.TextureMapID) {
    // t_ := rl.LoadTexture(path)
    // s.textures[id] = t_
}
free_state :: proc(s: ^State) {
    for id, ss in s.textures {
        fmt.println("Freed:", id);
        rl.UnloadTexture(ss.texture);
    }
    // free maps and arrays
    delete(s.textures)
    delete(s.entities)
}
handle_events :: proc(s: ^State) {
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

update :: proc(s: ^State, dt: f32) {
    for _, e in s.entities {
        e.state = .Idle
        if !e.attacking {
            if e.velocity.x != 0 || e.velocity.y != 0 {
                e.state = .Running
            }
            if e.in_attack_animation {
                e.state = .Attacking
            }
            e.pos += e.velocity * dt
        } else {
            e.state = .Attacking
            // hard coded
            if e.frame_time > ATTACK_FRAME {
                e.attacking = false
                e.to_deal_damage = true
            }
            e.pos += e.velocity * dt * e.attack_speed_slow_down
        }

        // e.pos.x - e.draw_rect.width / 2,
        // body center 2 thirds down the texture
        // e.pos.y - e.draw_rect.height / 3 * 2,
        e.body.x, e.body.y = e.pos.x - e.body.width / 2, e.pos.y - e.body.height / 2
        if e.velocity.y != 0 {
            if e.velocity.y > 0 {
                e.direction = EntityDirection.Down
            } else {
                e.direction = EntityDirection.Up
            }
        }
        if e.velocity.x != 0 {
            if e.velocity.x > 0 {
                e.direction = EntityDirection.Right
            } else {
                e.direction = EntityDirection.Left
            }
        }
        if e.to_deal_damage {
            // attack entities in range
            entity_attack_entities(s, e)
            e.to_deal_damage = false
        }
        e.frame_time += dt * FPS
        draw_update_entity_animation(s, e, dt)
    }
}

draw_update_entity_animation :: proc(s: ^State, e: ^Entity, dt: f32) {
    if e.previous_state != e.state {
        e.previous_state = e.state
        e.frame_time = 0
    }
    frames : f32= f32(s.textures[.Ranger].animation_info[e.state].length)
    ss_row : f32= f32(s.textures[.Ranger].animation_info[e.state].row)
    img_width : f32 = f32(s.textures[.Ranger].sprite_w)
    img_height : f32 = f32(s.textures[.Ranger].sprite_h)
    fmt.println(frames, ss_row, img_width, img_height)
    fmt.println(math.floor(e.frame_time), math.floor(frames), math.floor(e.frame_time) >= math.floor(frames), e.frame_time)

    // frames - 1 to have it within bounds
    if math.floor(e.frame_time) >= math.floor(frames - 1) {
        fmt.println("over frames", e.frame_time, frames)
        if e.state == .Attacking {
            fmt.println("over frames (in attack state)", e.frame_time, frames)
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

sort_entities :: proc(entities: [dynamic]^Entity) {
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

draw :: proc(s: ^State) {
    player := s.player

    entities: [dynamic]^Entity
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
    s := State{}

    t_ := rl.LoadTexture("assets/elemental_ranger/Elementals_leaf_ranger_288x128_SpriteSheet.png")

    ss := src.SpriteSheet{}
    ss.texture = t_
    ss.sprite_w = 288
    ss.sprite_h = 128
    ss.rows = 17
    ss.cols = 22

    a := src.SS_Animation_Data {
        row = 0, length = 12,
    }
    ss.animation_info[.Idle] = a
    b := src.SS_Animation_Data {
        row = 1, length = 10,
    }
    ss.animation_info[.Running] = b

    s.textures[.Ranger] = ss
    // fmt.println(s)
    p := Player{
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
    test_entity := Entity{
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
main :: proc() {
    main_1()
    // fmt.println(network_test())
}
