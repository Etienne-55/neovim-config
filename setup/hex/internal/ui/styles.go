package ui

import (
	"fmt"

	"hex/internal/keymaps"

	"github.com/charmbracelet/lipgloss"
)

// A Hades II palette on the terminal's black: Melinoë's witch-fire greens,
// bone for the text, a moonlit night for the rest.
var (
	ColorAccent   = lipgloss.Color("#45b072") // witch-fire: the prompt, help keys, legend
	ColorBorder   = lipgloss.Color("#2c6b45")
	ColorText     = lipgloss.Color("#d6d2c4") // bone
	ColorMuted    = lipgloss.Color("#4a6655") // moss
	ColorSubtle   = lipgloss.Color("#7d9484")
	ColorRule     = lipgloss.Color("#1f3a2a")
	ColorSelected = lipgloss.Color("#0f2a1b")
	ColorDark     = lipgloss.Color("#050b07")
	ColorBad      = lipgloss.Color("#b8433f")
)

// Each school of hexes gets a darker jewel tone: the greens of the
// Crossroads, Selene's moonlight, Hecate's violets, embers and old gold.
var categoryColors = map[keymaps.Category]lipgloss.Color{
	keymaps.Navigation:  lipgloss.Color("#3e9b5f"), // emerald witch-fire
	keymaps.Telescope:   lipgloss.Color("#2f8f7a"), // jade, a scrying pool
	keymaps.Git:         lipgloss.Color("#a8863a"), // tarnished gold
	keymaps.LSP:         lipgloss.Color("#4f7fa3"), // moonlit steel
	keymaps.Diagnostics: lipgloss.Color("#a8403c"), // blood, for curses
	keymaps.Editing:     lipgloss.Color("#6f9a3c"), // moss
	keymaps.Claude:      lipgloss.Color("#b8693a"), // ember copper
	keymaps.Completion:  lipgloss.Color("#3f8c8c"), // verdigris
	keymaps.UI:          lipgloss.Color("#8a8f86"), // ash
	keymaps.Tmux:        lipgloss.Color("#7a52a3"), // Hecate's violet
	keymaps.Shell:       lipgloss.Color("#95527d"), // Nyx's plum
}

var (
	mutedStyle  = lipgloss.NewStyle().Foreground(ColorMuted)
	subtleStyle = lipgloss.NewStyle().Foreground(ColorSubtle)
	textStyle   = lipgloss.NewStyle().Foreground(ColorText)
	accentStyle = lipgloss.NewStyle().Foreground(ColorAccent)
	ruleStyle   = lipgloss.NewStyle().Foreground(ColorRule)
	badStyle    = lipgloss.NewStyle().Foreground(ColorBad)
)

// shade darkens a color toward black: 1 keeps it, 0 is black.
func shade(c lipgloss.Color, factor float64) lipgloss.Color {
	rgb := hexRGB(string(c))
	return lipgloss.Color(fmt.Sprintf("#%02x%02x%02x",
		int(float64(rgb[0])*factor), int(float64(rgb[1])*factor), int(float64(rgb[2])*factor)))
}
