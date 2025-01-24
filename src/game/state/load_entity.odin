package state

import "core:encoding/json"
import "core:os"
import "core:io"
import "core:fmt"

EntityData :: struct {

}



parse_entity :: proc(bytes: []byte) -> (entity:EntityData, err:json.Unmarshal_Error){
    object : map[string]any
    if v, err := json.parse(bytes, parse_integers = true); err != nil {
        fmt.eprintln("Failed to unmarshal json:", err)
        return {}, err
    } else {
        data := v.(json.Object)
        fmt.println(data)
        fmt.println(data["body"])
    }

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
