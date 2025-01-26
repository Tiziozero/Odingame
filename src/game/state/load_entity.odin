package state

import "core:encoding/json"
import "core:os"
import "core:io"
import "core:fmt"
import entity_module "../entity"
import animations "../animations"


LoadingError :: enum {
    InvalidFormat,
    FailedToParse,
    FailedToOpenFile,
}


parse_entity :: proc(bytes: []byte) -> (entity:entity_module.Entity_Data, err:LoadingError){
    using fmt;
    data : json.Object
    sprite_sheet : json.Object
    animations_data : json.Object
    x_offset, y_offset, width, height: f64
    if v, err := json.parse(bytes, parse_integers = true); err != nil {
        fmt.eprintln("Failed to unmarshal json:", err)
        return {}, LoadingError.FailedToParse
    } else {
        ok: bool
        data, ok = v.(json.Object)
        if !ok {
            return {}, LoadingError.InvalidFormat
        }
    }

    body, ok := data["body"].(json.Object)
    if !ok {
        eprintln("Failed to find body in configuration/invalid format")
        return entity, LoadingError.InvalidFormat
    }
    sprite_sheet, ok = data["sprite"].(json.Object)
    if !ok {
        eprintln("Failed to find sprite in configuration/invalid format")
        return entity, LoadingError.InvalidFormat
    }
    animations_data, ok = data["animations"].(json.Object)
    if !ok {
        eprintln("Failed to find sprite in configuration/invalid format")
        return entity, LoadingError.InvalidFormat
    }

    // body
    x_offset, ok = body["x"].(json.Float)
    if !ok {
        eprintln("Failed to find body/x_offset in configuration/invalid format")
        return entity, LoadingError.InvalidFormat
    }
    y_offset, ok = body["y"].(json.Float)
    if !ok {
        eprintln("Failed to find body/y_offset in configuration/invalid format")
        return entity, LoadingError.InvalidFormat
    }

    width, ok = body["width"].(json.Float)
    if !ok {
        eprintln("Failed to find body/width in configuration/invalid format")
        return entity, LoadingError.InvalidFormat
    }
    height, ok = body["height"].(json.Float)
    if !ok {
        eprintln("Failed to find body/height in configuration/invalid format")
        return entity, LoadingError.InvalidFormat
    }

    // get attack animations
    animation_iter := animations_data["attack"].(json.Object)["base"].(json.Array)
    animations_array : map[entity_module.EntityAttacks]entity_module.Attack_Data

    // assume this doesn't fail
    for a,_  in animation_iter {



    }

    // sprite data




    ss := animations.SpriteSheet{}

    return {}, nil
}

load_entity ::proc(
    path: string = "assets/elemental_ranger/data.json"
) -> (ret_data: []byte, err:os.Error) {
    fmt.println("Load entity:", path)
    handler := os.open(path) or_return;
    defer os.close(handler)
    data, ok := os.read_entire_file_from_handle(handler);
    fmt.println(string(data))
    fmt.println(parse_entity(data))
    fmt.println("end load entity")
    return data, nil
}
