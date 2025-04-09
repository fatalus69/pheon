package lexer;

import "core:fmt"
import "core:os"

lexer_func :: proc() {
    fmt.println("YOYO from lexer")
}
// Token {
//     kind: TokenKind,
//     lexeme: string,
//     line: int,
//     column: int,
// }