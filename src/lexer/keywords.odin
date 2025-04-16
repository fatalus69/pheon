package lexer;

import "core:fmt"
import "core:os"
import "core:strings"
import "core:mem"

keywords: []string = {"echo", "if"} 

handleKeywords :: proc(value: string, keyword_token: ^KeywordToken) ->(^KeywordToken) {
  line: string = strings.trim_space(value)
  if strings.has_prefix(value, "$") {
    return nil
  }

  //TODO: recursion => e.g. nested if'S
  for keyword in keywords {
    if strings.contains(line, keyword) {
      line, _ := strings.replace(line, keyword, "", -1)
      line = strings.trim_space(line)
      
      args := make([dynamic]string)
      
      opening_arg_bracket: int = strings.index(line, "(")
      if opening_arg_bracket == 0 {
        closing_bracket: int = strings.index(line, ")")
        args_string: string = strings.cut(line, opening_arg_bracket + 1, closing_bracket - 1)
        
        //For multiple Arguments
        if strings.contains(args_string, ",") {
          arguments: []string = strings.split(args_string, ",")
          for &argument in arguments {
            argument = strings.trim_space(argument)
            if strings.contains(argument, "\"") {
              argument, _ = strings.replace(argument, "\"", "", -1)
            }
            append(&args, argument)
          }
        } else {
          args_string = strings.trim_space(args_string)
          if strings.contains(args_string, "\"") {
              args_string, _ = strings.replace(args_string, "\"", "", -1)
            }  
          append(&args, args_string)
        }
   
        keyword_token.name = keyword
        keyword_token.line = current_line
        keyword_token.args = args[:]

        return keyword_token
      }
    }
  }
  return nil
}
