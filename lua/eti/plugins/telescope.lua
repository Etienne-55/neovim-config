return {
  "nvim-telescope/telescope.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local builtin = require("telescope.builtin")
    local finders = require("telescope.finders")
    local pickers = require("telescope.pickers")
    local previewers = require("telescope.previewers")
    local conf = require("telescope.config").values
    local transform_mod = require("telescope.actions.mt").transform_mod

    local trouble = require("trouble")
    local trouble_telescope = require("trouble.sources.telescope")

    -- or create your custom action
    local custom_actions = transform_mod({
      open_trouble_qflist = function(prompt_bufnr)
        trouble.toggle("quickfix")
      end,
    })

    telescope.setup({
      defaults = {
        path_display = { "smart" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next, -- move to next result
            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
            ["<C-t>"] = trouble_telescope.open,
          },
        },
      },
    })

    telescope.load_extension("fzf")

    -- when nvim was launched from the shell only to host a picker, <Esc> should
    -- quit back to the terminal; inside a session it just closes the picker
    local function quit_on_escape(prompt_bufnr, map)
      map({ "i", "n" }, "<Esc>", function()
        actions.close(prompt_bufnr)
        vim.cmd("qall")
      end)
      return true
    end

    local function picker_opts(opts, from_shell)
      if from_shell then
        opts.attach_mappings = quit_on_escape
      end
      return opts
    end

    -- pick a directory, then find files in it (<cr>) or grep in it (<C-g>)
    local function find_directory(from_shell)
      pickers
        .new({}, {
          prompt_title = "Directories",
          finder = finders.new_oneshot_job(
            { "fd", "--type", "d", "--hidden", "--exclude", ".git" },
            { entry_maker = function(line)
              return { value = line, display = line, ordinal = line }
            end }
          ),
          sorter = conf.generic_sorter({}),
          previewer = previewers.new_termopen_previewer({
            get_command = function(entry)
              return { "eza", "--all", "--long", "--git", "--icons=always", "--color=always", entry.value }
            end,
          }),
          attach_mappings = function(prompt_bufnr, map)
            local function pick(fn)
              return function()
                local dir = action_state.get_selected_entry().value
                actions.close(prompt_bufnr)
                fn(dir)
              end
            end
            actions.select_default:replace(pick(function(dir)
              builtin.find_files(picker_opts({ cwd = dir, prompt_title = "Files in " .. dir }, from_shell))
            end))
            map({ "i", "n" }, "<C-g>", pick(function(dir)
              builtin.live_grep(
                picker_opts({ search_dirs = { dir }, prompt_title = "Grep in " .. dir }, from_shell)
              )
            end))
            if from_shell then
              quit_on_escape(prompt_bufnr, map)
            end
            return true
          end,
        })
        :find()
    end

    vim.api.nvim_create_user_command("FindDirectory", function()
      find_directory()
    end, { desc = "Pick a directory" })

    -- entry point for the shell aliases: `nvim "+Pick find_files"`
    vim.api.nvim_create_user_command("Pick", function(o)
      if o.args == "directory" then
        return find_directory(true)
      end
      if type(builtin[o.args]) ~= "function" then
        return vim.notify("Pick: no such picker: " .. o.args, vim.log.levels.ERROR)
      end
      builtin[o.args](picker_opts({}, true))
    end, {
      nargs = 1,
      desc = "Open a picker whose <Esc> quits nvim",
      complete = function(lead)
        local names = { "directory" }
        for name, fn in pairs(builtin) do
          if type(fn) == "function" then
            names[#names + 1] = name
          end
        end
        return vim.tbl_filter(function(name)
          return vim.startswith(name, lead)
        end, names)
      end,
    })

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
    keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
    keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
    keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
    keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
    keymap.set("n", "<leader>fd", find_directory, { desc = "Find directory, then files (<cr>) / grep (<C-g>)" })

    -- git (previews show the diff)
    keymap.set("n", "<leader>gd", "<cmd>Telescope git_status<cr>", { desc = "Changed files with diff preview" })
    keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "Browse commits with diff preview" })
    keymap.set("n", "<leader>gb", "<cmd>Telescope git_bcommits<cr>", { desc = "Browse buffer commits with diff preview" })
    keymap.set("n", "<leader>gB", "<cmd>Telescope git_branches<cr>", { desc = "Browse git branches" })
  end,
}
