import gleam/list.{Continue, Stop}
import gleam/string
import gleam/result
import gleam/string_builder
import interpreter/token.{type Token, Token, type TokenType}
import string_ext/string_ext

pub type Lexer {
    Lexer(input: List(String), position: Int, read_position: Int, current_ch: String)
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

pub fn next_token(lexer: Lexer) -> #(Token, Lexer) {
    let lexer = lexer |> skip_whitespace

    case lexer.current_ch {
        "=" -> with_static_token(token.assign, lexer)
        "+" -> with_static_token(token.plus, lexer)
        "(" -> with_static_token(token.l_paren, lexer)
        ")" -> with_static_token(token.r_paren, lexer)
        "{" -> with_static_token(token.l_brace, lexer)
        "}" -> with_static_token(token.r_brace, lexer)
        "," -> with_static_token(token.comma, lexer)
        ";" -> with_static_token(token.semicolon, lexer)
        "" -> with_static_token(token.eof, lexer)
        v -> case v |> string_ext.is_letter {
            True -> {
                let #(identifier, new_lexer) = lexer |> read_ident

                #(Token(lookup_ident(identifier), identifier), new_lexer)
            }
            False -> {
                case v |> string_ext.is_digit {
                    True -> {
                        let #(number, new_lexer) = lexer |> read_number
                        #(Token(token.int, number), new_lexer)
                    } 
                    False -> {
                        with_static_token(token.illegal, lexer)
                    }
                }
                
            }
        }
    }
}

fn with_static_token(token_type: TokenType, lexer: Lexer) -> #(Token, Lexer) {
    #(Token(token_type, lexer.current_ch), lexer |> read_char())
}

fn lookup_ident(ident: String) -> TokenType {
    case ident {
        "let" -> token.var
        "fn" -> token.func
        _ -> token.ident
    }
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

fn read_ident(lexer: Lexer) -> #(String, Lexer) {
    lexer |> read_atom(string_ext.is_letter)
}

fn read_number(lexer: Lexer) -> #(String, Lexer) {
    lexer |> read_atom(string_ext.is_digit)
}

fn read_atom(lexer: Lexer, identify_atom: fn(String) -> Bool) -> #(String, Lexer) {
    let final_identifier_builder =
        lexer.input
        |> list.drop(lexer.position)
        |> list.fold_until(string_builder.new(), fn(acc, char) {
            case char |> identify_atom {
                True -> Continue(acc |> string_builder.append(char))
                False -> Stop(acc) 
            }
    })
    
    let final_identifier = final_identifier_builder |> string_builder.to_string

    #(final_identifier, lexer |> adapt_to_position(lexer.position + string.length(final_identifier)))
}

fn adapt_to_position(lexer: Lexer, position: Int) -> Lexer {
     Lexer(..lexer, position: position, read_position: position + 1, current_ch: lexer |> char_at(position))
}

fn char_at(lexer: Lexer, position: Int) -> String {
    lexer.input |> list.at(position) |> result.unwrap("")
}
