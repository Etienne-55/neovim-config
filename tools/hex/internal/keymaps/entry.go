// Package keymaps reads the key bindings out of the neovim config, the tmux
// config and the zshrc, so the cheat sheet always shows what the config
// actually does instead of a list that goes stale.
package keymaps

// Category groups the bindings into the cheat sheet's tabs.
type Category int

const (
	Navigation Category = iota
	Telescope
	Git
	LSP
	Diagnostics
	Editing
	Claude
	Completion
	UI
	Tmux
	Shell
)

// Categories lists every category in tab order.
var Categories = []Category{Navigation, Telescope, Git, LSP, Diagnostics, Editing, Claude, Completion, UI, Tmux, Shell}

var categoryNames = map[Category]string{
	Navigation:  "Navigation",
	Telescope:   "Telescope",
	Git:         "Git",
	LSP:         "LSP",
	Diagnostics: "Diagnostics",
	Editing:     "Editing",
	Claude:      "Claude",
	Completion:  "Completion",
	UI:          "UI",
	Tmux:        "Tmux",
	Shell:       "Shell",
}

func (c Category) String() string { return categoryNames[c] }

// Entry is one binding.
type Entry struct {
	Keys    string // as written in the config: "<leader>ff", "C-b e"
	Display string // compact form for the list: "␣ff", "⌃b e"
	Modes   string // vim modes ("nx"); empty for tmux and shell
	Desc    string

	// DescIsCode is set when the config gives no description, and Desc is
	// the mapping's code instead.
	DescIsCode bool

	Note     string // longer explanation, shown in the detail line
	Action   string // right-hand side / command
	Scope    string // where it applies: "picker", "markdown", "copy mode"...
	Category Category
	File     string // path shown to the user
	Path     string // absolute path, to open the definition
	Line     int
}
