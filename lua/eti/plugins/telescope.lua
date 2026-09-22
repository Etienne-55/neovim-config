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

    -- pick a directory, then find files in it (<cr>) or grep in it (<C-g>)
    local function find_directory()
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
              builtin.find_files({ cwd = dir, prompt_title = "Files in " .. dir })
            end))
            map({ "i", "n" }, "<C-g>", pick(function(dir)
              builtin.live_grep({ search_dirs = { dir }, prompt_title = "Grep in " .. dir })
            end))
            return true
          end,
        })
        :find()
    end

    vim.api.nvim_create_user_command("FindDirectory", find_directory, { desc = "Pick a directory" })

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
