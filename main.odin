package main

import "core:fmt"
import "core:math"
import "core:mem"
import "core:time"

import rl "vendor:raylib"

IMAGE_WIDTH :: 96
IMAGE_HEIGHT :: 96
FPS :: 10
EntityDirection :: enum {
    Up,
    Down,
    Left,
    Right,
}
EntityState :: enum {
    Idle,
    Running,
    Attacking,
}
TextureMapID :: enum {
    PlayerIdle,
    PlayerRunning,
    PlayerAttack,
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
    state: EntityState,
    previous_state: EntityState,
    hp: f32,
    // animations
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
    textures: map[TextureMapID]rl.Texture2D,
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
entity_attack :: proc(s: ^State, e: ^Entity) {
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

state_add_texture :: proc(s: ^State, path: cstring, id: TextureMapID) {
    t_ := rl.LoadTexture(path)
    s.textures[id] = t_
}
free_state :: proc(s: ^State) {
    for id, texture in s.textures {
        fmt.println("Freed:", id);
        rl.UnloadTexture(texture);
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
            player.state = .Attacking;
            player.attacking = true
            player.in_attack_animation = true
            fmt.println("Attacking")
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
            if e.frame_time > 5 {
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
            entity_attack(s, e)
            e.to_deal_damage = false
        }
        e.frame_time += dt * FPS
        draw_update_entity_animation(e, dt)
    }
}

draw_update_entity_animation :: proc(e: ^Entity, dt: f32) {
    if e.previous_state != e.state {
        e.previous_state = e.state
        e.frame_time = 0
    }
    #partial switch e.state {
    case .Idle:
        FRAMES :: 10
        if e.frame_time > FRAMES { // frames
            // fmt.println("over frames", e.frame_time, FRAMES)
            e.frame_time -= FRAMES
        }
        index := math.floor(e.frame_time) * IMAGE_WIDTH
        i := 1
        if e.direction == .Left || e.direction == .Up {
            index += IMAGE_WIDTH
            i = -1
        }
        e.source_rect.x = index
        e.source_rect.width = f32(IMAGE_WIDTH * i)

    case .Running:
        FRAMES :: 16
        if e.frame_time > FRAMES { // frames
            // fmt.println("over frames", e.frame_time, FRAMES)
            e.frame_time -= FRAMES
        }
        index := math.floor(e.frame_time) * IMAGE_WIDTH
        i := 1
        if e.direction == .Left || e.direction == .Up {
            index += IMAGE_WIDTH
            i = -1
        }
        e.source_rect.x = index
        e.source_rect.width = f32(IMAGE_WIDTH * i)

    case .Attacking:
        FRAMES :: 7
        if e.frame_time > FRAMES { // frames
            //fmt.println("over frames (in attack state)", e.frame_time, FRAMES)
            e.frame_time -= FRAMES
            e.in_attack_animation = false
        } else {
            e.in_attack_animation = true
        }
        index := math.floor(e.frame_time) * IMAGE_WIDTH
        i := 1
        if e.direction == .Left || e.direction == .Up {
            index += IMAGE_WIDTH
            i = -1
        }
        e.source_rect.x = index
        e.source_rect.width = f32(IMAGE_WIDTH * i)
    }
}

sort_entities :: proc(entities: [dynamic]^Entity) {
    for i in 1..<len(entities) {
        p := entities[i-1].pos.y
        n := entities[i].pos.y
        if p > n {
            t := entities[i-1]
            entities[i-1] = entities[i]
            entities[i] = t
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
        draw_v := rl.Vector2{
            e.pos.x - e.draw_rect.width / 2,
            // body center 2 thirds down the texture
            e.pos.y - e.draw_rect.height / 3 * 2,
        }
        rl.DrawRectangleRec(e.body, rl.Color{255,112, 10, 58});        // rl.DrawCircleV(e.pos, 2, rl.WHITE);
        rl.DrawCircleV(e.pos, f32(e.attack_range), rl.Color{0,112, 198, 58});        // rl.DrawCircleV(e.pos, 2, rl.WHITE);
    }
    for e in entities {
        animation_index: TextureMapID
        #partial switch e.state {
        case .Running: animation_index = .PlayerRunning
        case .Idle: animation_index = .PlayerIdle
        case .Attacking: animation_index = .PlayerAttack
        case: animation_index = .PlayerIdle
        }

        draw_v := rl.Vector2{
            e.pos.x - e.draw_rect.width / 2,
            // body center 2 thirds down the texture
            e.pos.y - e.draw_rect.height / 3 * 2,
        }
        rl.DrawTextureRec(s.textures[animation_index], e.source_rect,
            draw_v, {255,255,255,255});
    }
    for e in entities {
        rl.DrawCircleV(e.pos, 2, rl.Color{0,112, 198, 58});
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
    p := Player{
        // position
        body={width=32, height=32},
        speed=200,
        // render
        draw_rect={width=96, height=96},
        // to reflect just use negative width and height
        source_rect={width=96, height=96, x=0, y=0},
        
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
    }
    test_entity := Entity{
        pos =  {300,300},
        // position
        body={width=32, height=32},
        speed=200,
        // render
        draw_rect={width=96, height=96},
        // to reflect just use negative width and height
        source_rect={width=96, height=96, x=0, y=0},
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
    }

    s.player = &p
    s.entities[0] = &p
    s.entities[1] = &test_entity
    state_add_texture(&s, "assets/idle.png", .PlayerIdle)
    state_add_texture(&s, "assets/run.png", .PlayerRunning)
    state_add_texture(&s, "assets/attack.png", .PlayerAttack)

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
    fmt.println(network_test())
}
