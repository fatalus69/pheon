package lexer;

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

//TODO what if a variable gets declared inside of a block (e.g. if block) SCOPE
//TODO handle ok returns for strings.replace's
//TODO Think about if to use only int & float or i8, i16, i32, .. (same for floats and maybe long)
//TODO check if its actually a variable being declared or its only being called for processing (like in a if statement)
handleVariable :: proc(line: string, token: ^Token) -> (^Token) {
  if strings.has_prefix(line, "$") {
    if strings.contains(line, "=") {
      // Single variable that has a value specified on initializiation
      parts: []string = strings.split(line, "=")

      if !strings.contains(parts[0], ":") {
        new_value, _ := strings.replace(parts[1], ";", "", -1)
        new_value = strings.trim_space(new_value)
        
        buf: [4]byte
        var_name_arr: []string = {strings.trim_space(parts[0]), "@", strconv.itoa(buf[:], current_line)} 
        
        var_name: string = strings.concatenate(var_name_arr[:])
        var_name = strings.trim_left(var_name, "$")

        for variable in variables {
          variable_name: string = strings.trim_space(strings.split(variable, "@")[0])
          my_var_name: string = strings.trim_space(strings.split(var_name, "@")[0])
          
          if my_var_name == variable_name {
            existing_type: string = variables[variable].type
            
            if !checkValueForType(new_value, existing_type) {
              error(current_line, "Error assigning value")
            }

            if existing_type == "string" {
              new_value, _ = strings.replace(new_value, "\"", "", -1)
            }

            token.name = my_var_name
            token.type = existing_type
            token.value = new_value
            token.scope = variables[variable].scope

            return token
          }
        }
      }

      //Declaration
      var_name, var_type := getDeclaration(parts[0])

      // Value
      value, ok := strings.replace(parts[1], ";", "", -1)
      value = strings.trim_space(value)

      if !checkValueForType(value, var_type) {
        error(current_line, "Error setting value")
      }

      if var_type == "string" {
        value, ok = strings.replace(value, "\"", "", -1)
      }

      token.name = var_name
      token.type = var_type
      token.value = value
      token.scope = "global" //Use global as default

    } else {
      // initializiation without setting a value 
      var_name, var_type := getDeclaration(line)

      token.name = var_name
      token.type = var_type
      token.value = ""
      token.scope = "global"
    }
    return token
  }
  return nil
}

checkValueForType :: proc(value: string, type: string) -> bool {
  err: bool = false
  switch type {
  case "int":
    bits := 64
    _, err := strconv.parse_i64_of_base(value, 10, &bits)
  case "float":
    bits := 64
    _, err := strconv.parse_f64(value, &bits)
  case "bool":
    _, err := strconv.parse_bool(value)
  case "string" :
    //TODO research if you can actually check for a string without a regex cause this isnt working: 
    //return !strings.contains_any(value, "\"") 
    return true
  }
  //Fall back
  return err
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
  allowed_types: []string = {"int", "float", "string", "bool", "array"}
  for allowed_type in allowed_types {
    if type == allowed_type {
      return true
    }
  }
  return false
}
