package keymaps

import "strings"

// The parser reads just enough Lua for the places bindings are declared:
// expressions, table constructors and call arguments. Function bodies are
// skipped whole; nothing is evaluated beyond string literals and their
// concatenation.

type nodeKind int

const (
	nOther nodeKind = iota
	nStr
	nName // a name or dotted chain: vim.lsp.buf.hover
	nCall // name is the callee when it is a plain chain
	nTable
	nFunc
	nConcat
	nNil
)

type node struct {
	kind       nodeKind
	str        string  // nStr: the value
	name       string  // nName, nCall: the dotted chain ("" when not a plain one)
	fields     []field // nTable
	parts      []*node // nConcat
	start, end int     // token range [start, end)
}

type field struct {
	name  string // name = value
	key   *node  // [key] = value
	value *node
}

// positional returns the table's fields that have no key, in order.
func (n *node) positional() []*node {
	var out []*node
	for _, f := range n.fields {
		if f.name == "" && f.key == nil {
			out = append(out, f.value)
		}
	}
	return out
}

// field returns the value of the table's named field, or nil.
func (n *node) field(name string) *node {
	if n == nil || n.kind != nTable {
		return nil
	}
	for _, f := range n.fields {
		if f.name == name {
			return f.value
		}
	}
	return nil
}

// strs returns a string literal's value, or a table's positional string
// literals: what `mode = "n"` and `mode = { "n", "x" }` both hold.
func (n *node) strs() []string {
	if n == nil {
		return nil
	}
	switch n.kind {
	case nStr:
		return []string{n.str}
	case nTable:
		var out []string
		for _, v := range n.positional() {
			if v.kind == nStr {
				out = append(out, v.str)
			}
		}
		return out
	}
	return nil
}

// eval evaluates a string expression: a literal, or literals concatenated
// with loop variables (env maps each variable to its values, joined).
func eval(n *node, env map[string]string) (string, bool) {
	if n == nil {
		return "", false
	}
	switch n.kind {
	case nStr:
		return n.str, true
	case nName:
		v, ok := env[n.name]
		return v, ok
	case nConcat:
		var b strings.Builder
		for _, part := range n.parts {
			s, ok := eval(part, env)
			if !ok {
				return "", false
			}
			b.WriteString(s)
		}
		return b.String(), true
	}
	return "", false
}

type parser struct {
	toks []token
}

func (p *parser) tok(i int) token {
	if i < 0 || i >= len(p.toks) {
		return token{kind: tkEOF}
	}
	return p.toks[i]
}

// is reports whether token i is the symbol or keyword text.
func (p *parser) is(i int, text string) bool {
	t := p.tok(i)
	return (t.kind == tkSym || t.kind == tkName) && t.text == text
}

var binops = map[string]bool{
	"..": true, "+": true, "-": true, "*": true, "/": true, "//": true, "%": true, "^": true,
	"==": true, "~=": true, "<": true, ">": true, "<=": true, ">=": true,
	"&": true, "|": true, "~": true, "<<": true, ">>": true, "and": true, "or": true,
}

func (p *parser) isBinop(i int) bool {
	t := p.tok(i)
	return (t.kind == tkSym || t.kind == tkName) && binops[t.text]
}

// expr parses an expression starting at token i, returning it and the index
// of the token after it. It always consumes at least one token.
func (p *parser) expr(i int) (*node, int) {
	first, j := p.unary(i)
	if !p.isBinop(j) {
		return first, j
	}
	n := &node{kind: nConcat, parts: []*node{first}, start: i}
	for p.isBinop(j) {
		if p.tok(j).text != ".." {
			n.kind = nOther
		}
		var next *node
		next, j = p.unary(j + 1)
		n.parts = append(n.parts, next)
	}
	n.end = j
	return n, j
}

func (p *parser) unary(i int) (*node, int) {
	if p.is(i, "-") || p.is(i, "#") || p.is(i, "~") || p.is(i, "not") {
		_, j := p.unary(i + 1)
		return &node{kind: nOther, start: i, end: j}, j
	}
	return p.primary(i)
}

var literals = map[string]bool{"true": true, "false": true, "...": true}

func (p *parser) primary(i int) (*node, int) {
	t := p.tok(i)
	n := &node{start: i}
	j := i + 1
	switch {
	case t.kind == tkString:
		n.kind, n.str = nStr, t.val
	case t.kind == tkNumber, literals[t.text]:
	case p.is(i, "nil"):
		n.kind = nNil
	case p.is(i, "function"):
		n.kind = nFunc
		j = p.skipBlock(i + 1)
		n.end = j
		return n, j
	case t.kind == tkName:
		n.kind, n.name = nName, t.text
	case p.is(i, "{"):
		return p.table(i)
	case p.is(i, "("):
		j = p.skipBalanced(i)
	default:
		n.end = j
		return n, j
	}
	return p.suffixes(n, j)
}

// suffixes parses what can follow a primary expression: field access,
// indexing, method calls and calls.
func (p *parser) suffixes(n *node, j int) (*node, int) {
	for {
		switch {
		case p.is(j, ".") && p.tok(j+1).kind == tkName:
			if n.kind == nName {
				n.name += "." + p.tok(j+1).text
			} else {
				n.kind, n.name = nOther, ""
			}
			j += 2
		case p.is(j, ":") && p.tok(j+1).kind == tkName:
			n.kind, n.name = nOther, ""
			j += 2
		case p.is(j, "["):
			n.kind, n.name = nOther, ""
			j = p.skipBalanced(j)
		case p.is(j, "("):
			if n.kind != nName {
				n.name = ""
			}
			n.kind = nCall
			j = p.skipBalanced(j)
		case p.is(j, "{"):
			if n.kind != nName {
				n.name = ""
			}
			n.kind = nCall
			_, j = p.table(j)
		case p.tok(j).kind == tkString:
			if n.kind != nName {
				n.name = ""
			}
			n.kind = nCall
			j++
		default:
			n.end = j
			return n, j
		}
	}
}

// table parses a table constructor whose { is at token i.
func (p *parser) table(i int) (*node, int) {
	n := &node{kind: nTable, start: i}
	j := i + 1
	for j < len(p.toks) && !p.is(j, "}") {
		var f field
		switch {
		case p.is(j, "["):
			f.key, j = p.expr(j + 1)
			if p.is(j, "]") {
				j++
			}
			if p.is(j, "=") {
				j++
			}
			f.value, j = p.expr(j)
		case p.tok(j).kind == tkName && p.is(j+1, "="):
			f.name = p.tok(j).text
			f.value, j = p.expr(j + 2)
		default:
			f.value, j = p.expr(j)
		}
		n.fields = append(n.fields, f)
		if p.is(j, ",") || p.is(j, ";") {
			j++
		} else if !p.is(j, "}") {
			j++ // not valid Lua; skip the token so parsing moves on
		}
	}
	n.end = j + 1
	return n, j + 1
}

// callArgs parses the arguments of a call whose ( is at token i.
func (p *parser) callArgs(i int) ([]*node, int) {
	var args []*node
	j := i + 1
	if p.is(j, ")") {
		return nil, j + 1
	}
	for j < len(p.toks) {
		var arg *node
		arg, j = p.expr(j)
		args = append(args, arg)
		switch {
		case p.is(j, ","):
			j++
		case p.is(j, ")"):
			return args, j + 1
		default:
			return args, p.skipBalanced(i)
		}
	}
	return args, j
}

var blockOpeners = map[string]bool{"function": true, "if": true, "do": true, "repeat": true}

// skipBlock returns the index past the `end` closing a block whose body
// starts at token i (for a function, just after the `function` keyword).
// A for or while loop opens its block with `do`, so only `do` is counted.
func (p *parser) skipBlock(i int) int {
	depth := 1
	for j := i; j < len(p.toks); j++ {
		t := p.toks[j]
		if t.kind != tkName {
			continue
		}
		switch {
		case blockOpeners[t.text]:
			depth++
		case t.text == "end" || t.text == "until":
			depth--
			if depth == 0 {
				return j + 1
			}
		}
	}
	return len(p.toks)
}

// skipBalanced returns the index past the bracket closing the one at i.
func (p *parser) skipBalanced(i int) int {
	depth := 0
	for j := i; j < len(p.toks); j++ {
		t := p.toks[j]
		if t.kind != tkSym {
			continue
		}
		switch t.text {
		case "(", "[", "{":
			depth++
		case ")", "]", "}":
			depth--
			if depth == 0 {
				return j + 1
			}
		}
	}
	return len(p.toks)
}

// text returns the source of tokens [start, end) on one line: comments
// dropped, and each run of whitespace squeezed to a single space.
func (p *parser) text(start, end int) string {
	var b strings.Builder
	for k := start; k < end && k < len(p.toks); k++ {
		t := p.toks[k]
		if k > start && t.off > p.toks[k-1].end {
			b.WriteByte(' ')
		}
		b.WriteString(t.text)
	}
	return strings.Join(strings.Fields(b.String()), " ")
}
