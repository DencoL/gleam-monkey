import gleam/list.{Continue, Stop}
import gleam/string
import gleam/result
import gleam/string_builder
import interpreter/token.{type Token, Token, type TokenType}
import string_ext/string_ext

pub type Lexer {
  Lexer(
    input: List(String),
    position: Int,
    read_position: Int,
    current_ch: String
  )
}

pub type UpdatedLexer(data) {
  UpdatedLexer(data: data, lexer: Lexer)
}

pub fn new(input: String) -> Lexer {
  Lexer(input: input |> string.split(on: ""), position: 0, read_position: 0, current_ch: "")
  |> read_char
}

fn read_char(lexer: Lexer) -> Lexer {
  let new_current_ch = case lexer.read_position >= list.length(lexer.input) {
    True -> ""
    False -> lexer |> char_at(lexer.read_position)
  }

  Lexer(
    ..lexer,
    position: lexer.read_position,
    read_position: lexer.read_position + 1,
    current_ch: new_current_ch
  )
}

pub fn next_token(lexer: Lexer) -> UpdatedLexer(Token) {
  let lexer = lexer |> skip_whitespace

  lexer.current_ch
  |> token.find_keyword_token
  |> try_keyword_token(lexer)
  |> try_token(read_ident, fn(identifier) { token.find_identifier(identifier) }, lexer)
  |> try_token(read_number, fn(_) { token.int }, lexer)
  |> eof_or_illegal(lexer)
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

fn try_keyword_token(
  keyword_token_result: Result(TokenType, Nil),
  lexer: Lexer
) -> Result(UpdatedLexer(Token), Nil) {
  keyword_token_result 
  |> result.map(fn(found_keyword_token_type) {
    UpdatedLexer(Token(found_keyword_token_type, lexer.current_ch), lexer |> read_char())
  })
}

fn try_token(
  failed_keyword_token_result: Result(UpdatedLexer(Token), Nil),
  token_identify_fun: fn(Lexer) -> Result(UpdatedLexer(String), Nil),
  lookup_identifier: fn(String) -> TokenType,
  lexer: Lexer
) -> Result(UpdatedLexer(Token), Nil) {
  failed_keyword_token_result
  |> result.try_recover(fn(_) {
    lexer
    |> token_identify_fun
    |> result.map(fn(updated_lexer) { 
      UpdatedLexer(
        Token(lookup_identifier(updated_lexer.data), updated_lexer.data),
        updated_lexer.lexer
      )
    })
  })
}

fn eof_or_illegal(
  failed_result: Result(UpdatedLexer(Token),
  Nil), lexer: Lexer
) -> UpdatedLexer(Token) {
  failed_result
  |> result.lazy_unwrap(fn() {
    let token = case lexer.current_ch {
      "" -> Token(token.eof, "")
      _ -> Token(token.illegal, lexer.current_ch)
    }

    UpdatedLexer(token, lexer |> read_char)
  })
}

fn read_ident(lexer: Lexer) -> Result(UpdatedLexer(String), Nil) {
  lexer |> read_continuous(string_ext.is_letter)
}

fn read_number(lexer: Lexer) -> Result(UpdatedLexer(String), Nil) {
  lexer |> read_continuous(string_ext.is_digit)
}

fn read_continuous(
  lexer: Lexer,
  identify_continuity: fn(String) -> Bool
) -> Result(UpdatedLexer(String), Nil) {
  let final_identifier_builder =
    lexer.input
    |> list.drop(lexer.position)
    |> list.fold_until(string_builder.new(), fn(acc, char) {
      case char |> identify_continuity {
        True -> Continue(acc |> string_builder.append(char))
        False -> Stop(acc) 
      }
  })

  case final_identifier_builder |> string_builder.is_empty {
    True -> Error(Nil)
    False -> {
      let final_identifier = final_identifier_builder |> string_builder.to_string
      let new_position = lexer.position + string.length(final_identifier)

      Ok(UpdatedLexer(final_identifier, lexer |> adapt_to_position(new_position)))
    }
  }
}

fn adapt_to_position(lexer: Lexer, position: Int) -> Lexer {
  Lexer(
    ..lexer,
    position: position,
    read_position: position + 1,
    current_ch: lexer |> char_at(position)
  )
}

fn char_at(lexer: Lexer, position: Int) -> String {
  lexer.input
  |> list.at(position)
  |> result.unwrap("")
}
