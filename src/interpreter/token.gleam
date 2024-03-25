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
pub const ident = TokenType("ident")
pub const int = TokenType("int")
pub const func = TokenType("func")

pub const illegal = TokenType("illegal")
