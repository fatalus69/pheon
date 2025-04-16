package main;

import "lexer"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:path/filepath"
import "core:strconv"

variables := map[string]lexer.Token{}
keywords := map[string]lexer.KeywordToken{}

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
  
  accumulated_lines: string = ""

  for content in strings.split_lines_iterator(&lines) {
    trimmed: string = strings.trim_space(content)
    if trimmed == "" {
      continue
    }
    
    string_arr: []string = {trimmed, " "}
    another_string_arr: []string = {accumulated_lines, strings.concatenate(string_arr[:])}
    
    accumulated_lines = strings.concatenate(another_string_arr[:])

    if strings.has_suffix(trimmed, ";") {
      token, type := lexer.lexerInit(line_counter, accumulated_lines, &variables)

      if token.variable != nil {
        variables[token.variable.name] = token.variable^
      }else if token.keyword != nil {
        if _, found := keywords[token.keyword.name]; !found {
          keywords[token.keyword.name] = token.keyword^
        } else {
          buf: [4]byte
          arr: []string = {token.keyword.name, "_", strconv.itoa(buf[:], line_counter)}
          keywords[strings.concatenate(arr[:])] = token.keyword^
        }
      } 
      accumulated_lines = ""
    } 
    line_counter += 1
  }
  fmt.println(variables)
  fmt.println(keywords)
}
