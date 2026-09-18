-- completes css class names inside class="..." from the stylesheets linked in the file
-- (<link href="..."> local files and CDN urls like bootstrap) plus the global ones below
return {
  "Jezda1337/nvim-html-css",
  dependencies = { "hrsh7th/nvim-cmp", "nvim-treesitter/nvim-treesitter" },
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
}
