package main;

import "lexer"
import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
    if (len(os.args) < 2) {
        os.exit(1)
    }

    file_path := os.args[1]
    handleFile(file_path)
}

handleFile :: proc(filepath: string) {
    data, ok := os.read_entire_file(filepath, context.allocator)
    if !ok {
        fmt.println("That didnt work man")
        return
    }
    defer delete(data, context.allocator)

    new_data := string(data)
    for line, content in strings.split_lines_iterator(&new_data) {
        fmt.println(line)
        fmt.println(content)
    }

    lexer_func()
}