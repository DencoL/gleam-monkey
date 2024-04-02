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

const tab = 9
const lf = 10
const cr = 13
const space = 32

pub fn is_whitespace(value: String) -> Bool {
    case value |> string.to_utf_codepoints {
        [char] -> {
            let char_as_int: Int = char |> string.utf_codepoint_to_int

            char_as_int == tab || char_as_int == lf || char_as_int == cr || char_as_int == space
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
