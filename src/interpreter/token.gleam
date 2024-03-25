pub type TokenType = String

pub type Token {
    Token(token_type: TokenType, literal: String)
}

pub const eof = "eof"
pub const assign = "="
pub const plus = "+"
pub const l_paren = "("
pub const r_paren = ")"
pub const l_brace = "{"
pub const r_brace = "}"
pub const comma = ","
pub const semicolon = ";"
pub const var = "let"
pub const ident = "ident"
pub const int = "int"
pub const func = "func"

pub const illegal = "illegal"

