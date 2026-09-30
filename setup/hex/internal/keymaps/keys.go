package keymaps

import (
	"regexp"
	"strings"
	"unicode/utf8"
)

var modifierGlyphs = map[byte]string{'c': "⌃", 'm': "⌥", 'a': "⌥", 's': "⇧", 'd': "⌘"}

var vimNamedKeys = map[string]string{
	"cr": "⏎", "enter": "⏎", "return": "⏎", "esc": "Esc", "bs": "⌫", "backspace": "⌫",
	"tab": "⇥", "space": "␣", "up": "↑", "down": "↓", "left": "←", "right": "→",
	"del": "⌦", "delete": "⌦", "bar": "|", "lt": "<", "bslash": `\`,
	"home": "Home", "end": "End", "pageup": "PgUp", "pagedown": "PgDn",
}

var tmuxNamedKeys = map[string]string{
	"enter": "⏎", "escape": "Esc", "bspace": "⌫", "tab": "⇥", "btab": "⇧⇥", "space": "␣",
	"up": "↑", "down": "↓", "left": "←", "right": "→", "dc": "⌦",
	"home": "Home", "end": "End", "ppage": "PgUp", "pageup": "PgUp", "npage": "PgDn", "pagedown": "PgDn",
}

var functionKey = regexp.MustCompile(`^f\d{1,2}$`)

// prettyVimKeys writes vim key notation compactly: "<leader>ff" reads
// "␣ff", "<C-S-P>" "⌃⇧P", "<M-Up>" "⌥↑".
func prettyVimKeys(lhs, leader string) string {
	var b strings.Builder
	for i := 0; i < len(lhs); {
		if lhs[i] == '<' {
			if j := strings.IndexByte(lhs[i+1:], '>'); j > 0 {
				if key, ok := prettyVimKey(lhs[i+1:i+1+j], leader); ok {
					b.WriteString(key)
					i += j + 2
					continue
				}
			}
		}
		r, size := utf8.DecodeRuneInString(lhs[i:])
		b.WriteRune(r)
		i += size
	}
	return b.String()
}

func prettyVimKey(name, leader string) (string, bool) {
	switch strings.ToLower(name) {
	case "leader":
		return leaderGlyph(leader), true
	case "localleader":
		return "LL", true
	}
	var mods strings.Builder
	for len(name) > 2 && name[1] == '-' {
		glyph, ok := modifierGlyphs[lower(name[0])]
		if !ok {
			return "", false
		}
		mods.WriteString(glyph)
		name = name[2:]
	}
	if utf8.RuneCountInString(name) > 1 {
		switch key := strings.ToLower(name); {
		case vimNamedKeys[key] != "":
			name = vimNamedKeys[key]
		case functionKey.MatchString(key):
			name = strings.ToUpper(key)
		default:
			return "", false
		}
	}
	return mods.String() + name, true
}

func leaderGlyph(leader string) string {
	if leader == " " {
		return "␣"
	}
	return leader
}

// prettyTmuxKey writes a tmux key the same way: "C-b" reads "⌃b".
func prettyTmuxKey(key string) string {
	var mods strings.Builder
	for len(key) > 2 && key[1] == '-' {
		glyph, ok := modifierGlyphs[lower(key[0])]
		if !ok {
			break
		}
		mods.WriteString(glyph)
		key = key[2:]
	}
	if named, ok := tmuxNamedKeys[strings.ToLower(key)]; ok && len(key) > 1 {
		key = named
	}
	return mods.String() + key
}

func lower(c byte) byte {
	if c >= 'A' && c <= 'Z' {
		return c + 'a' - 'A'
	}
	return c
}

var modeNames = map[rune]string{
	'n': "normal", 'v': "visual", 'x': "visual", 's': "select", 'o': "operator-pending",
	'i': "insert", 'c': "command line", 't': "terminal",
}

// ModeNames spells out a binding's modes: "nx" reads "normal, visual".
func ModeNames(modes string) string {
	var names []string
	seen := map[string]bool{}
	for _, m := range modes {
		if name := modeNames[m]; name != "" && !seen[name] {
			seen[name] = true
			names = append(names, name)
		}
	}
	return strings.Join(names, ", ")
}
