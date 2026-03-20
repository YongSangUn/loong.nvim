-- Manages configurations for plugins that improve the core text editing experience.
-- Covers text manipulation, movement, commenting, and structural editing.
local loong = require("core.loong")

-- file explor
-- https://github.com/nvim-tree/nvim-tree.lua
loong.add_plugin("nvim-tree/nvim-tree.lua", {
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  lazy = false,
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Open NvimTree", mode = "n" },
  },
  opts = {
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
    update_focused_file = { enable = true, update_root = true },
    filters = {
      git_ignored = false,
    },
  },
})

-- search
-- https://github.com/nvim-telescope/telescope.nvim
loong.add_plugin("nvim-telescope/telescope.nvim", {
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
    {
      "nvim-telescope/telescope-project.nvim",
      dependencies = {
        "nvim-telescope/telescope.nvim",
      },
    },
  },
  event = "VeryLazy",
  -- keys = {
  --   { "<leader>pp", "<cmd>Telescope projects<cr>", desc = "List Projects", mode = "n" },
  --   { "<leader>pf", "<cmd>Telescope find_files<cr>", desc = "List Project files", mode = "n" },
  --   { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Search text in current project", mode = "n" },
  -- },
  config = function()
    require("telescope").setup({})
    require("telescope").load_extension("project")
  end,
})

-- project
-- https://github.com/DrKJeff16/project.nvim
loong.add_plugin("DrKJeff16/project.nvim", {
  opts = {},
  config = function(_, opts)
    require("project").setup()
  end,
})

loong.add_plugin("towolf/vim-helm", {
  ft = "helm",
  config = function()
    vim.filetype.add({
      pattern = {
        -- Chart.yaml
        ["Chart.yaml"] = "helm",
        ["values.yaml"] = "helm",
        [".*templates/.*%.yaml"] = "helm",
        [".*templates/.*%.yml"] = "helm",
      },
    })
  end,
})

--- Treesitter
--- https://github.com/nvim-treesitter/nvim-treesitter/tree/main
--- ref: https://github.com/Shaobin-Jiang/IceNvim/blob/a11738f57ec371960ed7d13d7ec85a90834a81ca/lua/plugins/config.lua#L567
loong.add_plugin("nvim-treesitter/nvim-treesitter", {
  build = ":TSUpdate",
  branch = "main",
  config = function()
    -- stylua: ignore
    local ensure_installed = {
      "lua", "vim", "vimdoc",
      "bash", "powershell",
      "go", "python", "rust",
      "c", "cpp", "c_sharp",
      "css", "html", "javascript",
      "markdown", "markdown_inline",
      "json", "toml", "yaml", "helm",
      "sql",
    }
    local nvim_treesitter = require("nvim-treesitter")
    nvim_treesitter.setup()

    local pattern = {}
    for _, parser in ipairs(ensure_installed) do
      local has_parser, _ = pcall(vim.treesitter.language.inspect, parser)

      if not has_parser then
        -- Needs restart to take effect
        nvim_treesitter.install(parser)
      else
        vim.list_extend(pattern, vim.treesitter.language.get_filetypes(parser))
      end
    end
    local group = vim.api.nvim_create_augroup("NvimTreesitterFt", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = pattern,
      callback = function(ev)
        local max_filesize = 100 * 1024
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
        if not (ok and stats and stats.size > max_filesize) then
          vim.treesitter.start()
        end
      end,
    })

    vim.api.nvim_exec_autocmds("FileType", { group = "NvimTreesitterFt" })
  end,
})

-- terminal
-- toggleterm.setup()
-- https://github.com/akinsho/toggleterm.nvim
function _G.set_terminal_keymaps()
  -- ref: https://github.com/akinsho/toggleterm.nvim?tab=readme-ov-file#terminal-window-mappings
  local opts = { buffer = 0 }
  vim.keymap.set("t", "<esc><esc>", [[<C-\><C-n>]], opts)
end

loong.add_plugin("akinsho/toggleterm.nvim", {
  branch = "main",
  event = "BufRead",
  keys = {
    { "<leader>'", "<cmd>ToggleTerm<cr>", desc = "Open shell", mode = "n" },
    { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Open shell", mode = "n" },
    { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Open horizontal shell", mode = "n" },
    { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Open vertical shell", mode = "n" },
    { "<leader>tn", "<cmd>TermNew<cr>", desc = "Open new shell", mode = "n" },
  },
  config = function()
    require("toggleterm").setup({
      -- only set keymaps for toggleterm
      vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()"),
      on_open = function(term)
        vim.opt.laststatus = 3
      end,

      -- size can be a number or function which is passed the current terminal
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
    })
  end,
})

-- code navigation
-- https://github.com/folke/flash.nvim
loong.add_plugin("folke/flash.nvim", {
  event = "VeryLazy",
  opts = {},
  -- stylua: ignore
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
})

-- markdown
-- https://github.com/MeanderingProgrammer/render-markdown.nvim
loong.add_plugin("MeanderingProgrammer/render-markdown.nvim", {
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  ft = { "markdown", "Avante", "vimwiki" },
  opts = {
    completions = { blink = { enabled = true } },
    file_types = { "markdown", "vimwiki", "Avante" },
  },
})

-- autopairs
-- https://github.com/windwp/nvim-autopairs
loong.add_plugin("windwp/nvim-autopairs", {
  branch = "master",
  config = function()
    local autopairs = require("nvim-autopairs")
    autopairs.setup({
      disable_filetype = { "TelescopePrompt", "vim" },
    })
  end,
})

-- session
-- https://github.com/folke/persistence.nvim
loong.add_plugin("folke/persistence.nvim", {
  enabled = false,
  event = "BufReadPre",
  opts = {},
})

-- snacks.nvim
-- https://github.com/folke/snacks.nvim
loong.add_plugin("folke/snacks.nvim", {
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = false },
    dashboard = {
      preset = {
        header = [[
                                                                   
      ████ ██████           █████      ██                    
     ███████████             █████                            
     █████████ ███████████████████ ███   ███████████  
    █████████  ███    █████████████ █████ ██████████████  
   █████████ ██████████ █████████ █████ █████ ████ █████  
 ███████████ ███    ███ █████████ █████ █████ ████ █████ 
██████  █████████████████████ ████ █████ █████ ████ ██████]],
        keys = {
          { icon = " ", key = "p", desc = "List Projects", action = ":lua Snacks.picker.projects()" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "/", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          -- { icon = " ", key = "s", desc = "Restore Session", action = ":lua Snacks.dashboard.pick('session')" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        -- {
        --   section = "terminal",
        --   cmd = "chafa "
        --     .. vim.fn.stdpath("config")
        --     .. "/static/dashboard.gif"
        --     .. " -f symbols -s 80x80 -c full"
        --     .. " --passthrough tmux"
        --     .. " --fg-only --symbols braille --clear",
        --   height = 24,
        --   width = 80,
        --   padding = 1,
        -- },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
    explorer = { enabled = false },
    indent = { enabled = true },
    input = { enabled = false },
    picker = {
      sources = {
        projects = {
          dev = { "~/yaml" },
          recent = true,
        },
      },
    },
    notifier = { enabled = false },
    quickfile = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
  },
  -- stylua: ignore
  keys = {
    -- Top Pickers & Explorer
    { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
    { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
    -- find
    { "<leader>pp", function() Snacks.picker.projects() end, desc = "Projects" },
    { "<leader>pf", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>bb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
    -- git
    -- { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
    -- { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
    -- { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
    -- { "<leader>gS", function() Snacks.picker.git_status() end, desc = "Git Status" },
    -- { "<leader>gs", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
    -- { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
    -- { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
    -- Grep
    { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
    -- search
    { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
    { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
    { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
    { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
    { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
    { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
    { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
    { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
    { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
    { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
    { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
    { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
    { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },
    { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
    -- LSP
    { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
    { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
    { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
    { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
    -- { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
    { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
    { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
  },
})

--- base 64
--- https://github.com/ovk/endec.nvim
loong.add_plugin("ovk/endec.nvim", {
  event = "VeryLazy",
  opts = {
    keymaps = {
      -- Decode Base64 in-place (normal mode)
      decode_base64_inplace = "gyb",
      -- Decode Base64 in-place (visual mode)
      vdecode_base64_inplace = "gyb",
      -- Decode Base64 in a popup (normal mode)
      decode_base64_popup = "gb",
      -- Decode Base64 in a popup (visual mode)
      -- Encode Base64 in-place (normal mode)
      encode_base64_inplace = "gB",
      -- Encode Base64 in-place (visual mode)
      vencode_base64_inplace = "gB",
      -- Decode Base64URL in-place (normal mode)
      decode_base64url_inplace = "gys",
      -- Decode Base64URL in-place (visual mode)
      vdecode_base64url_inplace = "gys",
      -- Decode Base64URL in a popup (normal mode)
      decode_base64url_popup = "gs",
      -- Decode Base64URL in a popup (visual mode)
      vdecode_base64url_popup = "gs",
      -- Encode Base64URL in-place (normal mode)
      encode_base64url_inplace = "gS",
      -- Encode Base64URL in-place (visual mode)
      vencode_base64url_inplace = "gS",
      -- Decode URL in-place (normal mode)
      decode_url_inplace = "gyl",
      -- Decode URL in-place (visual mode)
      vdecode_url_inplace = "gyl",
      -- Decode URL in a popup (normal mode)
      decode_url_popup = "gl",
      -- Decode URL in a popup (visual mode)
      vdecode_url_popup = "gl",
      -- Encode URL in-place (normal mode)
      encode_url_inplace = "gL",
      -- Encode URL in-place (visual mode)
      vencode_url_inplace = "gL",
    },
    popup = {
      width = { min = 10, max = 150 },
    },
  },
})

-- trouble
-- https://github.com/folke/trouble.nvim
loong.add_plugin("folke/trouble.nvim", {
  cmd = "Trouble",
  opts = {},
  keys = {
    {
      "<leader>lt",
      "<cmd>Trouble diagnostics toggle force=true<cr>",
      desc = "Diagnostics (Trouble)",
    },
    {
      "<leader>ls",
      "<cmd>Trouble symbols toggle pinned=true win={relative=true,position=right}<cr>",
      desc = "Symbols (Trouble)",
    },
    {
      "<leader>ll",
      "<cmd>Trouble loclist toggle<cr>",
      desc = "Location List (Trouble)",
    },
    {
      "<leader>lq",
      "<cmd>Trouble qflist toggle<cr>",
      desc = "Quickfix List (Trouble)",
    },
  },
})

-- auto folding and statuscol.
-- https://github.com/kevinhwang91/nvim-ufo
loong.add_plugin("kevinhwang91/nvim-ufo", {
  event = "BufReadPost",
  dependencies = {
    "kevinhwang91/promise-async",
    "nvim-treesitter/nvim-treesitter",
    -- clear the ugly numbers, foldinner nvim version 0.11.5 is not supported.
    -- also adjust the layout of the foldcolumn and number.
    --   ref: https://github.com/kevinhwang91/nvim-ufo/issues/4#top
    {
      "luukvbaal/statuscol.nvim",
      config = function()
        local builtin = require("statuscol.builtin")
        require("statuscol").setup({
          relculright = true,
          segments = {
            { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
            { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
            { text = { " %s" }, click = "v:lua.ScSa" },
          },
        })
      end,
    },
  },
  init = function()
    -- vim.o.foldcolumn = "1"
    vim.o.foldcolumn = "1"
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
    vim.o.fillchars = "eob: ,fold: ,foldopen:,foldsep: ,foldclose:"
  end,
  opts = {
    provider_selector = function()
      return { "treesitter", "indent" }
    end,
    -- show the number of folded lines
    fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
      local newVirtText = {}
      local suffix = (" ... 󰁂 %d lines"):format(endLnum - lnum)
      local sufWidth = vim.fn.strdisplaywidth(suffix)
      local targetWidth = width - sufWidth
      local curWidth = 0
      for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
          table.insert(newVirtText, chunk)
        else
          chunkText = truncate(chunkText, targetWidth - curWidth)
          table.insert(newVirtText, { chunkText, chunk[2] })
          curWidth = curWidth + vim.fn.strdisplaywidth(chunkText)
          if curWidth < targetWidth then
            table.insert(newVirtText, { " ", "UfoFoldedEllipsis" })
          end
          break
        end
        curWidth = curWidth + chunkWidth
      end
      table.insert(newVirtText, { suffix, "MoreMsg" })
      return newVirtText
    end,
  },
})
