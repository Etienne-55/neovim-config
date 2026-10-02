package keymaps

import (
	"os"
	"regexp"
	"strings"
)

var (
	aliasLine    = regexp.MustCompile(`^alias\s+([\w.-]+)=(.*)$`)
	functionLine = regexp.MustCompile(`^(?:function\s+)?([\w-]+)\s*\(\)\s*\{`)
)

// ParseShell reads a zshrc's aliases, and the functions that have a comment
// saying what they are for. display is the path shown for it.
func ParseShell(path, display string) ([]Entry, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	var entries []Entry
	var block []string
	for n, raw := range strings.Split(string(data), "\n") {
		text := strings.TrimSpace(raw)
		switch {
		case text == "":
			block = nil
			continue
		case strings.HasPrefix(text, "#"):
			block = addComment(block, text)
			continue
		}

		e := Entry{Category: Shell, File: display, Path: path, Line: n + 1}
		code, trailing := splitComment(text)
		if m := aliasLine.FindStringSubmatch(code); m != nil {
			e.Keys = m[1]
			if f := shellFields(m[2]); len(f) > 0 {
				e.Action = f[0].val
			}
		} else if m := functionLine.FindStringSubmatch(code); m != nil && len(block) > 0 {
			e.Keys = m[1]
			e.Action = m[1] + "()"
		}
		if e.Keys != "" {
			e.Display = e.Keys
			switch {
			case len(block) > 0:
				e.Desc, e.Note = commentDesc(block)
			case trailing != "":
				e.Desc = trailing
			default:
				e.Desc, e.DescIsCode = e.Action, true
			}
			entries = append(entries, e)
		}
		block = nil
	}
	return entries, nil
}
