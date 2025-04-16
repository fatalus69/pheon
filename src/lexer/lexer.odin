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
  scope: string, //determine where a variable is available e.g. globally, or only inside an if condition
}

//TODO only temporary, will probably be changed
KeywordToken :: struct {
  name: string,
  line: int,
  args: []string,
}

TokenResult :: struct {
  variable: ^Token,
  keyword: ^KeywordToken
}

lexerInit :: proc(line: int, content: string, passed_variables: ^map[string]Token) -> (TokenResult, string) {
  current_line = line
  variables = passed_variables

  default_return: TokenResult
  if strings.trim_space(content) == "" {
    default_return.variable = nil
    default_return.keyword = nil
    return default_return, ""
  }
  return tokenize(content)
} 

//TODO handle ok returns for strings.replace's
//TODO Think about if to use only int & float or i8, i16, i32, .. (same for floats)
// Returns the Token if it was a value that needs to be newly written to the map
tokenize :: proc(line_content: string) -> (TokenResult, string) {
  line: string = strings.trim_space(line_content)
  token: ^Token = new(Token)
  keyword_token: ^KeywordToken = new(KeywordToken)

  variable := handleVariable(line_content, token)
  keywords := handleKeywords(line_content, keyword_token)

  type: string = ""
  result: TokenResult

  //TODO what if both are not nil?
  if variable != nil {
    type = "variable"
    result.variable = variable
    result.keyword = nil
  } else if keywords != nil {
    type = "keyword"
    result.keyword = keywords
    result.variable = nil
  }

  return result, type
}

error :: proc(line: int, message: string) {
  buf: [64]u8
  line: i64 = cast(i64)line
  line_str: string = strconv.append_int(buf[:], line, 10)

  fmt.println("Error: ", message, " Thrown on line: ", line_str)
  os.exit(1)
}
