package main;

import "lexer"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:path/filepath"

variables := map[string]lexer.Token{}

main :: proc() {
  if (len(os.args) < 2) {
    os.exit(1)
  }

  filename: string = os.args[1]
    
  if (os.is_file(filename) && filepath.ext(filename) == ".pheon") {
    handleFile(filename)
  }  
}

handleFile :: proc(filepath: string) {
  data, ok := os.read_entire_file(filepath, context.allocator)
  if !ok {
      fmt.println("Error reading file")
      os.exit(1)
  }
  defer delete(data, context.allocator)

  lines := string(data)
  line_counter: int = 1
  
  for content in strings.split_lines_iterator(&lines) {
    token := lexer.lexerInit(line_counter, content, &variables)
    if token != nil {
      variables[token.name] = token^
    }
    
    line_counter += 1
  }

  fmt.println(variables)
}
