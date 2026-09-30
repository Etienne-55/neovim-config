package keymaps

import (
	"strconv"
	"strings"
)

type tokKind int

const (
	tkEOF tokKind = iota
	tkName
	tkString
	tkNumber
	tkSym
)

type token struct {
	kind     tokKind
	text     string // source text; a string's includes its quotes
	val      string // a string's value
	line     int
	off, end int // byte offsets in the source
}

var multiSyms = []string{"...", "..", "==", "~=", "<=", ">=", "::", "//", "<<", ">>"}

// lexLua splits Lua source into tokens. Comments are returned apart, keyed
// by the line they start on, so a mapping can use the one trailing it.
func lexLua(src string) (toks []token, comments map[int]string) {
	comments = map[int]string{}
	line := 1
	n := len(src)

	for i := 0; i < n; {
		c := src[i]
		switch {
		case c == '\n':
			line++
			i++

		case c == ' ' || c == '\t' || c == '\r' || c == '\f' || c == '\v':
			i++

		case c == '-' && i+1 < n && src[i+1] == '-':
			if lvl, ok := longBracket(src, i+2); ok {
				body, end := readLong(src, i+2, lvl)
				comments[line] = strings.TrimSpace(body)
				line += strings.Count(src[i:end], "\n")
				i = end
				continue
			}
			end := strings.IndexByte(src[i:], '\n')
			if end < 0 {
				end = n
			} else {
				end += i
			}
			comments[line] = strings.TrimSpace(src[i+2 : end])
			i = end

		case c == '"' || c == '\'':
			val, end, lines := readQuoted(src, i)
			toks = append(toks, token{kind: tkString, text: src[i:end], val: val, line: line, off: i, end: end})
			line += lines
			i = end

		case c == '[':
			if lvl, ok := longBracket(src, i); ok {
				body, end := readLong(src, i, lvl)
				toks = append(toks, token{kind: tkString, text: src[i:end], val: body, line: line, off: i, end: end})
				line += strings.Count(src[i:end], "\n")
				i = end
				continue
			}
			toks = append(toks, token{kind: tkSym, text: "[", line: line, off: i, end: i + 1})
			i++

		case isDigit(c) || (c == '.' && i+1 < n && isDigit(src[i+1])):
			j := i + 1
			for j < n && (isAlnum(src[j]) || (src[j] == '.' && !(j+1 < n && src[j+1] == '.'))) {
				j++
			}
			toks = append(toks, token{kind: tkNumber, text: src[i:j], line: line, off: i, end: j})
			i = j

		case isAlpha(c):
			j := i + 1
			for j < n && isAlnum(src[j]) {
				j++
			}
			toks = append(toks, token{kind: tkName, text: src[i:j], line: line, off: i, end: j})
			i = j

		default:
			size := 1
			for _, s := range multiSyms {
				if strings.HasPrefix(src[i:], s) {
					size = len(s)
					break
				}
			}
			toks = append(toks, token{kind: tkSym, text: src[i : i+size], line: line, off: i, end: i + size})
			i += size
		}
	}
	return toks, comments
}

// longBracket reports whether a long bracket ([[, [==[ ...) opens at i, and
// its level (the number of =).
func longBracket(src string, i int) (int, bool) {
	if i >= len(src) || src[i] != '[' {
		return 0, false
	}
	j := i + 1
	for j < len(src) && src[j] == '=' {
		j++
	}
	if j < len(src) && src[j] == '[' {
		return j - i - 1, true
	}
	return 0, false
}

// readLong reads a long string or comment opening at i, returning its body
// and the offset just past its closing bracket.
func readLong(src string, i, lvl int) (string, int) {
	start := i + lvl + 2
	closer := "]" + strings.Repeat("=", lvl) + "]"
	k := strings.Index(src[start:], closer)
	if k < 0 {
		return src[start:], len(src)
	}
	body := strings.TrimPrefix(src[start:start+k], "\n")
	return body, start + k + len(closer)
}

// readQuoted reads a quoted string opening at i, returning its value, the
// offset past its closing quote and the newlines it spans.
func readQuoted(src string, i int) (string, int, int) {
	quote := src[i]
	var b strings.Builder
	lines := 0
	j := i + 1
	for j < len(src) {
		c := src[j]
		switch {
		case c == quote:
			return b.String(), j + 1, lines
		case c == '\n': // unterminated
			return b.String(), j, lines
		case c == '\\' && j+1 < len(src):
			j++
			e := src[j]
			switch {
			case e == 'n':
				b.WriteByte('\n')
			case e == 't':
				b.WriteByte('\t')
			case e == 'r':
				b.WriteByte('\r')
			case e == '\n':
				b.WriteByte('\n')
				lines++
			case isDigit(e):
				k := j
				for k < len(src) && k < j+3 && isDigit(src[k]) {
					k++
				}
				v, _ := strconv.Atoi(src[j:k])
				b.WriteByte(byte(v))
				j = k - 1
			case e == 'x' && j+2 < len(src):
				v, err := strconv.ParseUint(src[j+1:j+3], 16, 8)
				if err == nil {
					b.WriteByte(byte(v))
					j += 2
				}
			case e == 'z':
				for j+1 < len(src) && strings.IndexByte(" \t\r\n", src[j+1]) >= 0 {
					if src[j+1] == '\n' {
						lines++
					}
					j++
				}
			default:
				b.WriteByte(e)
			}
			j++
		default:
			b.WriteByte(c)
			j++
		}
	}
	return b.String(), j, lines
}

func isDigit(c byte) bool { return c >= '0' && c <= '9' }
func isAlpha(c byte) bool { return c == '_' || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') }
func isAlnum(c byte) bool { return isAlpha(c) || isDigit(c) }
