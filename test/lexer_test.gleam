import gleeunit
import gleeunit/should
import interpreter/token.{type TokenType}
import interpreter/lexer.{type Lexer, Lexer}
import gleam/list

pub fn main() {
  gleeunit.main()
}

type LexerTest {
  LexerTest(expected_token_type: TokenType, expected_literal: String)
}

pub fn next_token_1_test() {
  let input = "=+(){},;#"

  let tests = [
    LexerTest(token.assign, "="),
    LexerTest(token.plus, "+"),
    LexerTest(token.l_paren, "("),
    LexerTest(token.r_paren, ")"),
    LexerTest(token.l_brace, "{"),
    LexerTest(token.r_brace, "}"),
    LexerTest(token.comma, ","),
    LexerTest(token.semicolon, ";"),
    LexerTest(token.illegal, "#"),
    LexerTest(token.eof, ""),
  ]

  tests
  |> list.fold(lexer.new(input), test_case)
}

pub fn next_token_2_test() {
  let input = "let five = 5;
let ten = 10;

let add = fn(x, y) {
  x + y
};

let result = add(five, ten);"

  let tests = [
    LexerTest(token.var, "let"),
    LexerTest(token.ident, "five"),
    LexerTest(token.assign, "="),
    LexerTest(token.int, "5"),
    LexerTest(token.semicolon, ";"),
    LexerTest(token.var, "let"),
    LexerTest(token.ident, "ten"),
    LexerTest(token.assign, "="),
    LexerTest(token.int, "10"),
    LexerTest(token.semicolon, ";"),
    LexerTest(token.var, "let"),
    LexerTest(token.ident, "add"),
    LexerTest(token.assign, "="),
    LexerTest(token.func, "fn"),
    LexerTest(token.l_paren, "("),
    LexerTest(token.ident, "x"),
    LexerTest(token.comma, ","),
    LexerTest(token.ident, "y"),
    LexerTest(token.r_paren, ")"),
    LexerTest(token.l_brace, "{"),
    LexerTest(token.ident, "x"),
    LexerTest(token.plus, "+"),
    LexerTest(token.ident, "y"),
    LexerTest(token.r_brace, "}"),
    LexerTest(token.semicolon, ";"),
    LexerTest(token.var, "let"),
    LexerTest(token.ident, "result"),
    LexerTest(token.assign, "="),
    LexerTest(token.ident, "add"),
    LexerTest(token.l_paren, "("),
    LexerTest(token.ident, "five"),
    LexerTest(token.comma, ","),
    LexerTest(token.ident, "ten"),
    LexerTest(token.r_paren, ")"),
    LexerTest(token.semicolon, ";"),
    LexerTest(token.eof, "")
  ]

  tests
  |> list.fold(lexer.new(input), test_case)
}

pub fn next_token_3_test() {
  let input = "!-/#*5;
5 < 10 > 5;
"

  let tests = [
    LexerTest(token.bang, "!"),
    LexerTest(token.minus, "-"),
    LexerTest(token.slash, "/"),
    LexerTest(token.illegal, "#"),
    LexerTest(token.asterisk, "*"),
    LexerTest(token.int, "5"),
    LexerTest(token.semicolon, ";"),
    LexerTest(token.int, "5"),
    LexerTest(token.lt, "<"),
    LexerTest(token.int, "10"),
    LexerTest(token.gt, ">"),
    LexerTest(token.int, "5"),
    LexerTest(token.semicolon, ";"),
  ]

  tests
  |> list.fold(lexer.new(input), test_case)
}

fn test_case(lexer: Lexer, test_case: LexerTest) -> Lexer {
  let updated_lexer = lexer |> lexer.next_token()
  let actual_token = updated_lexer.data

  actual_token.literal |> should.equal(test_case.expected_literal)
  actual_token.token_type |> should.equal(test_case.expected_token_type)

  updated_lexer.lexer
}
