-- completes css class names inside class="..." from the stylesheets linked in the file
-- (<link href="..."> local files and CDN urls like bootstrap) plus the global ones below
return {
  "Jezda1337/nvim-html-css",
  -- markup files only: its setup re-sources every plugin/ script and looks for ./.nvim.lua
  ft = {
    "html",
    "htmlangular",
    "htmldjango",
    "javascriptreact",
    "typescriptreact",
    "vue",
    "svelte",
    "php",
    "astro",
  },
  -- no nvim-cmp: it serves completions as an in-process LSP server, which cmp-nvim-lsp picks up
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    enable_on = {
      "html",
      "htmlangular",
      "htmldjango",
      "javascriptreact",
      "typescriptreact",
      "vue",
      "svelte",
      "php",
      "astro",
    },
    documentation = { auto_show = true },
    -- stylesheets available in every file, even without a <link> tag
    style_sheets = {
      -- bootstrap 3 (col-xs-*); switch to bootstrap@5.3.3 when the project upgrades
      "https://cdn.jsdelivr.net/npm/bootstrap@3.4.1/dist/css/bootstrap.min.css",
    },
  },
  config = function(_, opts)
    -- setup() runs ./.nvim.lua (its per-project config) with a bare dofile(), so a cloned
    -- repo's file ran unasked, and it switches 'exrc' on for the rest of the session.
    -- Only run that file once it's trusted (the vim.secure.read prompt, or :trust), and
    -- put 'exrc' back
    local exrc, run_file = vim.o.exrc, dofile
    dofile = function(path)
      local code = vim.secure.read(path)
      if code then
        return assert(loadstring(code, "@" .. path))()
      end
    end
    local ok, err = pcall(require("html-css").setup, opts)
    dofile, vim.o.exrc = run_file, exrc
    assert(ok, err)
  end,
}
