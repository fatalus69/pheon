package main;

import "lexer"
import "parser"
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
        buf: [4]byte
        var_name_arr: []string = {token.variable.name, "@", strconv.itoa(buf[:], line_counter)} 
        
        var_name: string = strings.concatenate(var_name_arr[:])
        var_name = strings.trim_left(var_name, "$")

        variables[var_name] = token.variable^
      }else if token.keyword != nil {
        buf: [4]byte
        keyword_name_arr: []string = {token.keyword.name, "@", strconv.itoa(buf[:], line_counter)}
        keyword_name: string = strings.concatenate(keyword_name_arr[:])

        keywords[keyword_name] = token.keyword^
      } 
      accumulated_lines = ""
    } 
    line_counter += 1
  }
  parser.parse(variables, keywords)
}
