import gleam/string

pub fn is_digit(value: String) -> Bool {
    case value |> string.to_utf_codepoints {
        [char] -> {
            let char_as_int: Int = char |> string.utf_codepoint_to_int

            char_as_int >= 48 && char_as_int <= 57
        }
        _ -> False
    }
}

pub fn is_whitespace(value: String) -> Bool {
    case value |> string.to_utf_codepoints {
        [char] -> {
            let char_as_int: Int = char |> string.utf_codepoint_to_int

                let is_whitespace =
                char_as_int == 9 ||
                char_as_int == 10 ||
                char_as_int == 13 ||
                char_as_int == 32

                is_whitespace
        }
        _ -> False
    }
}

pub fn is_letter(value: String) -> Bool {
    case value |> string.to_utf_codepoints {
        [char] -> {
            let char_as_int: Int = char |> string.utf_codepoint_to_int

            char_as_int >= 65 && char_as_int <= 90 ||
            char_as_int >= 97 && char_as_int <= 122
        }
        _ -> False
    }
}
