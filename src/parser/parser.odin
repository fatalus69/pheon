package parser;

import "../lexer"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:slice"

sorted: []string

parse :: proc(variables: map[string]lexer.Token, keywords: map[string]lexer.KeywordToken) {
  sortAndMerge(variables, keywords)

}

sortAndMerge :: proc(variables: map[string]lexer.Token, keywords: map[string]lexer.KeywordToken) {
  all_keys := make([dynamic]string) 

  for key in variables {
    append(&all_keys, key)
  }

  for  key in keywords {
    append(&all_keys, key)
  }
  
  sorted = sort(all_keys[:])
}

sort :: proc(keys: []string) -> ([]string) {
  slice.sort_by(keys, proc(a,b: string) -> (bool) {
    a_parts: []string = strings.split(a, "@")
    b_parts: []string = strings.split(b, "@")
    
    defer {
      delete(a_parts)
      delete(b_parts)
    }

    a_line, a_ok := strconv.parse_int(a_parts[1])
    b_line, b_ok := strconv.parse_int(b_parts[1])

    if !a_ok || !b_ok {
      return a < b
    }

    return a_line < b_line
  })

  return slice.clone(keys)
}
