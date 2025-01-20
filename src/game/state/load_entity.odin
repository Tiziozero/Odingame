package state

import "core:encoding/json"
import "core:os"
import "core:io"

EntityData :: struct {

}

load_entity ::proc(path: string = "assets/elemental_ranger/data.json") -> (data: EntityData, err:os.Error) {
    handler := os.open(path) or_return;
    defer os.close(handler)
    data_read : []byte
    bytes_read := os.read(handler, data_read) or_return;
    
    return {}, nil
}
