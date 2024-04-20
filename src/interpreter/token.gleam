import gleam/list
import gleam/option.{type Option}

pub type TokenType {
  TokenType(value: String)
}

pub type Token {
  Token(token_type: TokenType, literal: String)
}

pub const eof = TokenType("eof")
pub const assign = TokenType("=")
pub const plus = TokenType("+")
pub const l_paren = TokenType("(")
pub const r_paren = TokenType(")")
pub const l_brace = TokenType("{")
pub const r_brace = TokenType("}")
pub const comma = TokenType(",")
pub const semicolon = TokenType(";")
pub const var = TokenType("let")
pub const int = TokenType("int")
pub const func = TokenType("func")
pub const bang = TokenType("!")
pub const minus = TokenType("-")
pub const slash = TokenType("/")
pub const asterisk = TokenType("*")
pub const lt = TokenType("<")
pub const gt = TokenType(">")

pub const ident = TokenType("ident")
pub const illegal = TokenType("illegal")

const atomics = [
  assign,
  plus,
  l_paren,
  r_paren,
  l_brace,
  r_brace,
  comma,
  semicolon,
  int,
  bang,
  minus,
  slash,
  asterisk,
  lt,
  gt
]

const keyword_token_types = [
  eof,
  var,
  func
]

pub fn find_identifier(identifier: String) -> TokenType {
  case identifier {
    "let" -> var
    "fn" -> func
    _ -> ident
  }
}

pub fn find_keyword_token(token: String) -> Option(TokenType) {
  keyword_token_types
  |> list.append(atomics)
  |> list.find(fn(token_type) { token_type.value == token }) 
  |> option.from_result
}
