package keymaps

import (
	"os"
	"regexp"
	"strings"
)

// ParseTmux reads the bindings of a tmux config. display is the path shown
// for it ("~/.tmux.conf").
func ParseTmux(path, display string) ([]Entry, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	lines := joinContinuations(strings.Split(string(data), "\n"))

	prefix := "C-b"
	for _, l := range lines {
		words := fieldValues(shellFields(stripComment(l.text)))
		if len(words) >= 3 && (words[0] == "set" || words[0] == "set-option") && words[len(words)-2] == "prefix" {
			prefix = words[len(words)-1]
		}
	}

	var entries []Entry
	var block []string // the comment lines just above
	for _, l := range lines {
		text := strings.TrimSpace(l.text)
		switch {
		case text == "":
			block = nil
		case strings.HasPrefix(text, "#"):
			block = addComment(block, text)
		case strings.HasPrefix(text, "unbind"):
			// often frees the key the next line binds: keep its comment
		default:
			if e, ok := tmuxBinding(text, prefix, block); ok {
				e.File, e.Path, e.Line = display, path, l.number
				entries = append(entries, e)
			}
			block = nil
		}
	}
	return entries, nil
}

func tmuxBinding(text, prefix string, block []string) (Entry, bool) {
	code, trailing := splitComment(text)
	f := shellFields(code)
	if len(f) < 3 || (f[0].val != "bind" && f[0].val != "bind-key") {
		return Entry{}, false
	}

	table, note := "prefix", ""
	i := 1
	for i < len(f) && len(f[i].val) > 1 && f[i].val[0] == '-' {
		flags := f[i].val[1:]
		i++
		for _, c := range flags {
			switch c {
			case 'n':
				table = "root"
			case 'T':
				if i < len(f) {
					table = f[i].val
					i++
				}
			case 'N':
				if i < len(f) {
					note = f[i].val
					i++
				}
			}
		}
	}
	if i+1 >= len(f) {
		return Entry{}, false
	}
	key := f[i].val
	cmd := strings.TrimSpace(code[f[i+1].start:])

	e := Entry{Keys: key, Display: prettyTmuxKey(key), Action: cmd, Category: Tmux}
	switch table {
	case "prefix":
		e.Keys = prefix + " " + key
		e.Display = prettyTmuxKey(prefix) + " " + prettyTmuxKey(key)
	case "root":
	case "copy-mode-vi", "copy-mode":
		e.Scope = "copy mode"
	default:
		e.Scope = table
	}

	switch {
	case note != "":
		e.Desc = note
	case len(block) > 0:
		e.Desc, e.Note = commentDesc(block)
	case trailing != "":
		e.Desc = trailing
	default:
		e.Desc = humanizeTmux(cmd)
		e.DescIsCode = e.Desc == cmd
	}
	return e, true
}

var tmuxDirections = map[string]string{"-L": "left", "-D": "down", "-U": "up", "-R": "right"}

// humanizeTmux describes a tmux command that has no comment.
func humanizeTmux(cmd string) string {
	w := fieldValues(shellFields(cmd))
	if len(w) == 0 {
		return cmd
	}
	has := func(flag string) bool {
		for _, x := range w[1:] {
			if x == flag {
				return true
			}
		}
		return false
	}
	direction := func() string {
		for _, x := range w[1:] {
			if d, ok := tmuxDirections[x]; ok {
				return d
			}
		}
		return ""
	}
	last := w[len(w)-1]

	switch w[0] {
	case "split-window", "splitw":
		if has("-h") {
			return "Split the pane side by side"
		}
		return "Split the pane top / bottom"
	case "select-pane", "selectp":
		if d := direction(); d != "" {
			return "Go to the pane " + d
		}
	case "resize-pane", "resizep":
		if has("-Z") {
			return "Zoom the pane (toggle)"
		}
		if d := direction(); d != "" {
			return "Resize the pane " + d + " by " + last
		}
	case "source-file", "source":
		return "Reload " + last
	case "send-prefix":
		return "Send the prefix to the program"
	case "attach-session", "attach":
		if has("-c") {
			return "Make the current pane's directory the session's"
		}
	case "run-shell", "run":
		inner := strings.Fields(last)
		if len(inner) >= 3 && inner[0] == "tmux" && (inner[1] == "neww" || inner[1] == "new-window") {
			return "Run " + strings.Join(inner[2:], " ") + " in a new window"
		}
		return "Run " + last
	}
	return cmd
}

type numberedLine struct {
	number int
	text   string
}

// joinContinuations joins lines ending in a backslash with the next.
func joinContinuations(raw []string) []numberedLine {
	var out []numberedLine
	for n := 0; n < len(raw); n++ {
		l := numberedLine{number: n + 1, text: raw[n]}
		for strings.HasSuffix(strings.TrimRight(l.text, " \t"), `\`) && n+1 < len(raw) {
			n++
			head := strings.TrimSuffix(strings.TrimRight(l.text, " \t"), `\`)
			l.text = strings.TrimRight(head, " \t") + " " + strings.TrimSpace(raw[n])
		}
		out = append(out, l)
	}
	return out
}

var commentedCode = regexp.MustCompile(`^(bind|bind-key|unbind|set|set-option|setw|run|run-shell|if-shell|source|alias|export|eval|source-file)\b`)

// addComment adds a comment line to the block above a binding. Commented-out
// code isn't a description, so it ends the block instead.
func addComment(block []string, line string) []string {
	text := strings.TrimSpace(strings.TrimLeft(line, "#"))
	if commentedCode.MatchString(text) {
		return nil
	}
	return append(block, text)
}

var promptPrefix = regexp.MustCompile(`(?i)^(prefix\s*\+\s*\S+|<space>\S+)\s*[:\-–—]\s*`)

// commentDesc splits the comment above a binding into a short description -
// its first clause - and the whole comment as a note when it says more.
func commentDesc(block []string) (desc, note string) {
	full := promptPrefix.ReplaceAllString(strings.Join(block, " "), "")
	desc = full
	if k := strings.IndexAny(desc, ";"); k > 0 {
		desc = desc[:k]
	}
	if k := strings.Index(desc, ". "); k > 0 {
		desc = desc[:k]
	}
	if len(desc) > 60 {
		if k := strings.Index(desc, " ("); k > 0 {
			desc = desc[:k]
		}
	}
	desc = strings.TrimSuffix(strings.TrimSpace(desc), ".")
	if full != desc && strings.TrimSuffix(full, ".") != desc {
		note = full
	}
	return desc, note
}

type shellField struct {
	val        string
	start, end int
}

// shellFields splits a line into words, honouring quotes.
func shellFields(s string) []shellField {
	var out []shellField
	i := 0
	for i < len(s) {
		for i < len(s) && (s[i] == ' ' || s[i] == '\t') {
			i++
		}
		if i >= len(s) {
			break
		}
		start := i
		var b strings.Builder
		for i < len(s) && s[i] != ' ' && s[i] != '\t' {
			switch c := s[i]; c {
			case '"', '\'':
				end := strings.IndexByte(s[i+1:], c)
				if end < 0 {
					b.WriteString(s[i+1:])
					i = len(s)
					continue
				}
				b.WriteString(s[i+1 : i+1+end])
				i += end + 2
			case '\\':
				if i+1 < len(s) {
					b.WriteByte(s[i+1])
				}
				i += 2
			default:
				b.WriteByte(c)
				i++
			}
		}
		out = append(out, shellField{val: b.String(), start: start, end: i})
	}
	return out
}

func fieldValues(f []shellField) []string {
	out := make([]string, len(f))
	for i, x := range f {
		out[i] = x.val
	}
	return out
}

// splitComment splits a line at a # comment outside quotes.
func splitComment(s string) (code, comment string) {
	var quote byte
	for i := 0; i < len(s); i++ {
		c := s[i]
		switch {
		case quote != 0:
			if c == quote {
				quote = 0
			}
		case c == '"' || c == '\'':
			quote = c
		case c == '#' && (i == 0 || s[i-1] == ' ' || s[i-1] == '\t'):
			return strings.TrimSpace(s[:i]), strings.TrimSpace(s[i+1:])
		}
	}
	return strings.TrimSpace(s), ""
}

func stripComment(s string) string {
	code, _ := splitComment(s)
	return code
}
