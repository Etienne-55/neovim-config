package ui

import "github.com/charmbracelet/bubbles/key"

// listKeyMap holds the shortcuts while browsing the list.
type listKeyMap struct {
	Up, Down, PageUp, PageDown, Top, Bottom key.Binding
	PrevTab, NextTab                        key.Binding
	Filter, Clear, Open, Quit               key.Binding
}

// filterKeyMap holds the shortcuts while typing a filter, where every
// letter types: moving and switching tabs keep to keys that don't.
type filterKeyMap struct {
	Up, Down, PrevTab, NextTab key.Binding
	Accept, Cancel, Quit       key.Binding
}

// helpBindings adapts a plain list of bindings to help.KeyMap.
type helpBindings []key.Binding

func (b helpBindings) ShortHelp() []key.Binding  { return b }
func (b helpBindings) FullHelp() [][]key.Binding { return [][]key.Binding{b} }

var (
	ListKeys = listKeyMap{
		Up:       key.NewBinding(key.WithKeys("up", "k", "ctrl+p"), key.WithHelp("↑/↓", "move")),
		Down:     key.NewBinding(key.WithKeys("down", "j", "ctrl+n")),
		PageUp:   key.NewBinding(key.WithKeys("ctrl+u", "pgup", "b")),
		PageDown: key.NewBinding(key.WithKeys("ctrl+d", "pgdown", " ")),
		Top:      key.NewBinding(key.WithKeys("g", "home")),
		Bottom:   key.NewBinding(key.WithKeys("G", "end")),
		PrevTab:  key.NewBinding(key.WithKeys("left", "h", "shift+tab")),
		NextTab:  key.NewBinding(key.WithKeys("right", "l", "tab"), key.WithHelp("←/→", "category")),
		Filter:   key.NewBinding(key.WithKeys("/"), key.WithHelp("/", "filter")),
		Clear:    key.NewBinding(key.WithKeys("esc"), key.WithHelp("esc", "clear filter")),
		Open:     key.NewBinding(key.WithKeys("enter", "e"), key.WithHelp("enter", "edit in nvim")),
		Quit:     key.NewBinding(key.WithKeys("q", "ctrl+c"), key.WithHelp("q", "quit")),
	}

	FilterKeys = filterKeyMap{
		Up:      key.NewBinding(key.WithKeys("up", "ctrl+p", "ctrl+k"), key.WithHelp("↑/↓", "move")),
		Down:    key.NewBinding(key.WithKeys("down", "ctrl+n", "ctrl+j")),
		PrevTab: key.NewBinding(key.WithKeys("shift+tab")),
		NextTab: key.NewBinding(key.WithKeys("tab"), key.WithHelp("tab", "category")),
		Accept:  key.NewBinding(key.WithKeys("enter"), key.WithHelp("enter", "done")),
		Cancel:  key.NewBinding(key.WithKeys("esc"), key.WithHelp("esc", "clear")),
		Quit:    key.NewBinding(key.WithKeys("ctrl+c"), key.WithHelp("ctrl+c", "quit")),
	}
)
