package lexer;

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

current_line: int = 1;
variables : ^map[string]Token;

Token :: struct {
  name: string,
  type: string,
  value: string,
}

lexerInit :: proc(line: int, content: string, passed_variables: ^map[string]Token) -> (^Token) {
  current_line = line
  variables = passed_variables
  if content == "" {
    return nil
  }
  return tokenize(content)
} 

//TODO handle ok returns for strings.replace's
//TODO validate the value thats is being set to a variable, so a string variable doesnt hold an int
//TODO Think about if to use only int & float or i8, i16, i32, .. (same for floats)
// Returns the Token if it was a value that needs to be newly written to the map
tokenize :: proc(line_content: string) -> (^Token) {
  line: string = strings.trim_space(line_content)
  token: ^Token = new(Token)

  if strings.has_prefix(line, "$") {
    if strings.contains(line, "=") {
      // Single variable that has a value specified on initializiation
      parts: []string = strings.split(line, "=")
      
      if !strings.contains(parts[0], ":") {
        new_value, _ := strings.replace(parts[1], ";", "", -1)
        new_value = strings.trim_space(new_value)
        
        removed_dollar, _ := strings.replace(parts[0], "$", "", -1)
        var_name: string = strings.trim_space(removed_dollar)
        
        if var_name in variables {
          value := variables[var_name]

          if variables[var_name].type == "string" {
            new_value, _ = strings.replace(new_value, "\"", "", -1)
          }
          
          value.value = new_value
          variables[var_name] = value
          
          return nil
        } else {
          error(current_line, "Trying to set value to undeclared variable")
        }  
      }

      //Declaration
      var_name, var_type := getDeclaration(parts[0])

      // Value
      value, ok := strings.replace(parts[1], ";", "", -1)
      value = strings.trim_space(value)

      if var_type == "string" {
        value, ok = strings.replace(value, "\"", "", -1)
      }

      token.name = var_name
      token.type = var_type
      token.value = value
    } else {
      // initializiation without setting a value 
      // TODO currently sets Token.value to an empty string. => maybe set it to null or default value for each corresponding type
      var_name, var_type := getDeclaration(line)

      token.name = var_name
      token.type = var_type
    }
    return token;
  }
  
  //Assume there was no variable declaration or reassignment in the current line
  return nil;
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
