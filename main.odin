package main

import "core:fmt"
import "core:math"
import "core:time"

import rl "vendor:raylib"

IMAGE_WIDTH :: 96
IMAGE_HEIGHT :: 96

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
    pos: rl.Vector2,
    velocity: rl.Vector2,
    body: rl.Rectangle,
    speed: f32,

    // entity state
    state: EntityState,
    previous_state: EntityState,
    attack_1_frames: []int,
    // animations
    direction: EntityDirection,
    draw_rect: rl.Rectangle,
    source_rect: rl.Rectangle,
    frame_time: f32,
    fps: int,
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
            s.player.state = .Attacking;
            fmt.println("Attacking")
        }
        case : {} // default case
        }
        k = rl.GetKeyPressed()
    }
}

update :: proc(s: ^State, dt: f32) {
    draw_update_entity_animation(s, dt)
    player := s.player

    if s.player.state != .Attacking {
        if player.velocity.x != 0 || player.velocity.y != 0 {
            player.state = .Running
        } else {
            player.state = .Idle
        }
        player.pos += player.velocity * dt
        player.draw_rect.x, player.draw_rect.y = player.pos.x, player.pos.y
        if player.velocity.y != 0 {
            if player.velocity.y > 0 {
                player.direction = EntityDirection.Down
            } else {
                player.direction = EntityDirection.Up
            }
        }
        if player.velocity.x != 0 {
            if player.velocity.x > 0 {
                player.direction = EntityDirection.Right
            } else {
                player.direction = EntityDirection.Left
            }
        }
    } else { // attack
        
    }
}

draw_update_entity_animation :: proc(s: ^State, dt: f32) {
    for _, e in s.entities {
        if e.previous_state != e.state {
            e.previous_state = e.state
            e.frame_time = 0
        }
        #partial switch e.state {
        case .Idle: {
            FRAMES :: 10
            e.frame_time += dt * FRAMES
            if e.frame_time > FRAMES { // frames
                fmt.println("over frames", e.frame_time, FRAMES)
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
        }
        case .Running: {
            FRAMES :: 16
            e.frame_time += dt * FRAMES
            if e.frame_time > FRAMES { // frames
                fmt.println("over frames", e.frame_time, FRAMES)
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

        }
        }
    }
}
draw :: proc(s: ^State, idle_texture: rl.Texture2D) {
    player := s.player
    rl.BeginDrawing();

    rl.ClearBackground(rl.BLACK);
    for _, e in s.entities {
        animation_index: TextureMapID
        #partial switch e.state {
        case .Running: animation_index = .PlayerRunning
        case .Idle: animation_index = .PlayerIdle
        case .Attacking: animation_index = .PlayerAttack
        case: animation_index = .PlayerIdle
        }

        rl.DrawTextureRec(s.textures[animation_index], e.source_rect,
            e.pos, {255,255,255,255});
    }

    rl.EndDrawing();
}

main :: proc() {
    fmt.println("Start main")

    // init raylib
    rl.InitWindow(800, 500, "Hello from Odin!!!");
    rl.SetTargetFPS(60);

    // allocate memory for textures
    idle_texture := rl.LoadTexture("assets/idle.png")
    running_texture := rl.LoadTexture("assets/run.png")

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
        fps = 10,
        
        // state
        state = .Idle,
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
        fps = 10,
        // state
        state = .Idle,
    }

    s.textures[.PlayerIdle] = idle_texture
    s.textures[.PlayerRunning] = running_texture
    s.player = &p
    s.entities[0] = &p
    s.entities[1] = &test_entity

    for !rl.WindowShouldClose() && !s.quit {
        // fmt.println(p)
        dt := rl.GetFrameTime()

        handle_events(&s)
        update(&s, dt)
        draw(&s, idle_texture);
    }

    // free memory
    for _, texture in s.textures {
        rl.UnloadTexture(texture);
    }
    rl.CloseWindow();
    fmt.println("End main");
}
