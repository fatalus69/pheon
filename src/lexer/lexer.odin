package lexer;

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

current_line: int = 0;

Token :: struct {
  name: string,
  type: string,
  value: string,
  line: int,
}

lexerInit :: proc(line: int, content: string) {
  current_line = line
  tokenize(content)
} 

tokenize :: proc(line_content: string) {
  line: string = strings.trim_space(line_content)
  if strings.has_prefix(line, "$") {
    if strings.contains(line, "=") {
      parts: []string = strings.split(line, "=")
      
      //Declaration
      var_name, var_type := getDeclaration(parts[0])

      //Value: let ok be there for now, maybe check if its actually okay
      value, ok := strings.replace(parts[1], ";", "", -1)
      value = strings.trim_space(value)

      if (var_type == "string") {
        value, ok = strings.replace(value, "\"", "", -1)
      }

      fmt.println("Name: ", var_name, "\nType: ", var_type, "\nValue: ", value) 
    } else {
      var_name, var_type := getDeclaration(line)
      fmt.println("Name: ", var_name, "\nType: ", var_type)
    }
  } 
}

getDeclaration :: proc (declaration_string: string) -> (string, string) {
  declaration_parts: []string = strings.split(declaration_string, ":")
  if len(declaration_parts) < 2 {
    error(current_line, "Invalid declaration: Missing Type")
  }

  var_type: string = strings.trim_space(declaration_parts[1])
  
  if strings.has_suffix(var_type, ";") {
    var_type = strings.trim_right(var_type, ";")
  }

  if !validateType(var_type) {
    error_string: []string = {"Undefined type of ", var_type}
    error(current_line, strings.concatenate(error_string[:]))
  }
  
  var_name: string = strings.trim_space(declaration_parts[0])
  var_name = strings.trim_left(var_name, "$")

  return var_name, var_type
}

validateType :: proc(type: string) -> (bool) {
  allowed_types: []string = {"int", "string", "bool", "array"}
  for allowed_type in allowed_types {
    if type == allowed_type {
      return true
    }
  }
  return false
}

error :: proc(line: int, message: string) {
  buf: [64]u8
  line: i64 = cast(i64)line
  line_str: string = strconv.append_int(buf[:], line, 10)

  fmt.println("Error: ", message, " Thrown on line: ", line_str)
  os.exit(1)
}

// Token {
//     kind: TokenKind,
//     lexeme: string,
//     line: int,
//     column: int,
// }
