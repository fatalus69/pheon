package main;

import "lexer"
import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
    if (len(os.args) < 2) {
        os.exit(1)
    }

    handleFile(os.args[1])
}

handleFile :: proc(filepath: string) {
    data, ok := os.read_entire_file(filepath, context.allocator)
    if !ok {
        fmt.println("That didnt work man")
        return
    }
    defer delete(data, context.allocator)

    lines := string(data)
    line_counter := 1
    
    for content in strings.split_lines_iterator(&lines) { 
      lexer.lexer_init(line_counter, content)
      line_counter += 1
    }
}
