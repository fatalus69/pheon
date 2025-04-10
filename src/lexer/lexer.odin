package lexer;

import "core:fmt"
import "core:os"
import "core:strconv"

lexer_init :: proc(line: int, content: string) {
  //TODO parse lines to actually tokenize
  error(line, "Hey, dont execute")
} 

error :: proc(line: int, message: string) {
  buf: [64]u8
  line: i64 = cast(i64)line
  line_str := strconv.append_int(buf[:], line, 10)

  fmt.println("Error: ", message, " Thrown on line: ", line_str)
  os.exit(1)
}

// Token {
//     kind: TokenKind,
//     lexeme: string,
//     line: int,
//     column: int,
// }
