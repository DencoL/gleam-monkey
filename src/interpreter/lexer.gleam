import gleam/list.{Continue, Stop}
import gleam/string
import gleam/result
import gleam/string_builder
import interpreter/token.{type Token, Token, type TokenType}
import string_ext/string_ext

pub type Lexer {
    Lexer(input: List(String), position: Int, read_position: Int, current_ch: String)
}

pub type UpdatedLexer(data) {
    UpdatedLexer(data: data, lexer: Lexer)
}

pub fn new(input: String) -> Lexer {
    Lexer(input: input |> string.split(on: ""), position: 0, read_position: 0, current_ch: "") |> read_char
}

fn read_char(lexer: Lexer) -> Lexer {
    let new_current_ch = case lexer.read_position >= list.length(lexer.input) {
        True -> ""
        False -> lexer |> char_at(lexer.read_position)
    }

    Lexer(..lexer, position: lexer.read_position, read_position: lexer.read_position + 1, current_ch: new_current_ch)
}

pub fn next_token(lexer: Lexer) -> UpdatedLexer(Token) {
    let lexer = lexer |> skip_whitespace

    case lexer.current_ch {
        "=" -> create_static_updated_lexer(token.assign, lexer)
        "+" -> create_static_updated_lexer(token.plus, lexer)
        "(" -> create_static_updated_lexer(token.l_paren, lexer)
        ")" -> create_static_updated_lexer(token.r_paren, lexer)
        "{" -> create_static_updated_lexer(token.l_brace, lexer)
        "}" -> create_static_updated_lexer(token.r_brace, lexer)
        "," -> create_static_updated_lexer(token.comma, lexer)
        ";" -> create_static_updated_lexer(token.semicolon, lexer)
        "" -> create_static_updated_lexer(token.eof, lexer)
        v -> case v |> string_ext.is_letter {
            True -> {
                let updated_lexer = lexer |> read_ident

                create_updated_lexer(token.lookup_identifier(updated_lexer.data), updated_lexer)
            }
            False -> {
                case v |> string_ext.is_digit {
                    True -> {
                        let updated_lexer = lexer |> read_number
                        create_updated_lexer(token.int, updated_lexer)
                    } 
                    False -> {
                        create_static_updated_lexer(token.illegal, lexer)
                    }
                }
                
            }
        }
    }
}

fn create_updated_lexer(token_type: TokenType, lexer: UpdatedLexer(String)) -> UpdatedLexer(Token) {
    UpdatedLexer(Token(token_type, lexer.data), lexer.lexer)
}

fn create_static_updated_lexer(token_type: TokenType, lexer: Lexer) -> UpdatedLexer(Token) {
    UpdatedLexer(Token(token_type, lexer.current_ch), lexer |> read_char())
}

fn skip_whitespace(lexer: Lexer) -> Lexer {
    let new_position =
        lexer.input
        |> list.drop(lexer.position)
        |> list.fold_until(lexer.position, fn(acc, char) {
            case char |> string_ext.is_whitespace {
                True -> Continue(acc + 1)
                False -> Stop(acc) 
            }
    })

    lexer |> adapt_to_position(new_position)
}

fn read_ident(lexer: Lexer) -> UpdatedLexer(String) {
    lexer |> read_continuous(string_ext.is_letter)
}

fn read_number(lexer: Lexer) -> UpdatedLexer(String) {
    lexer |> read_continuous(string_ext.is_digit)
}

fn read_continuous(lexer: Lexer, identify_continuity: fn(String) -> Bool) -> UpdatedLexer(String) {
    let final_identifier_builder =
        lexer.input
        |> list.drop(lexer.position)
        |> list.fold_until(string_builder.new(), fn(acc, char) {
            case char |> identify_continuity {
                True -> Continue(acc |> string_builder.append(char))
                False -> Stop(acc) 
            }
    })
    
    let final_identifier = final_identifier_builder |> string_builder.to_string

    UpdatedLexer(final_identifier, lexer |> adapt_to_position(lexer.position + string.length(final_identifier)))
}

fn adapt_to_position(lexer: Lexer, position: Int) -> Lexer {
     Lexer(..lexer, position: position, read_position: position + 1, current_ch: lexer |> char_at(position))
}

fn char_at(lexer: Lexer, position: Int) -> String {
    lexer.input
    |> list.at(position)
    |> result.unwrap("")
}
