-- Contains configurations for plugins that provide and manage code completion functionalities.
-- This includes the main completion engine, snippet engines, and various completion sources.

local loong = require("core.loong")

loong.add_plugin(
  -- Auto completion
  -- https://github.com/saghen/blink.cmp
  -- https://cmp.saghen.dev/installation
  "saghen/blink.cmp",
  {
    dependencies = {
      "rafamadriz/friendly-snippets",
      "Kaiser-Yang/blink-cmp-avante", -- use for anante.nvim complation
    },
    version = "1.*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = { preset = "enter" },
      -- disable cmdline
      cmdline = { enabled = false },
      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = "mono",
      },
      completion = { documentation = { auto_show = true } },
      sources = {
        -- default = { 'avante', 'lsp', 'path', 'snippets', 'buffer' },
        -- promblem for avante, ref:
        --   https://github.com/Kaiser-Yang/blink-cmp-avante/issues/7#issuecomment-2865110680
        default = function()
          local ft = vim.bo.filetype
          if ft == "DressingInput" then
            -- return { 'path', 'buffer' }
            return {}
          end
          local ss = { "lsp", "path", "snippets", "buffer" }
          if ft == "AvanteInput" then
            ss = { "avante" }
          elseif vim.tbl_contains({ "markdown", "Avante" }, vim.bo.filetype) then
            vim.list_extend(ss, { "buffer" }) -- , 'ripgrep', 'dictionary' })
          end
          return ss
        end,
        providers = {
          -- https://github.com/Kaiser-Yang/blink-cmp-avante?tab=readme-ov-file#lazynvim
          avante = {
            module = "blink-cmp-avante",
            name = "Avante",
            opts = {},
          },
        },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  }
)

-- auto_suggestions
-- https://github.com/supermaven-inc/supermaven-nvim
loong.add_plugin("supermaven-inc/supermaven-nvim", {
  -- enabled = false,
  opts = {
    keymaps = {
      accept_suggestion = "<Tab>",
      clear_suggestion = "<C-]>",
      accept_word = "<C-j>",
    },
    ignore_filetypes = { "Avante", "TelescopePrompt" },
    -- color = {
    --   suggestion_color = "#ffffff",
    --   cterm = 244,
    -- },
  },
})

-- avante
-- https://github.com/yetone/avante.nvim
loong.add_plugin("yetone/avante.nvim", {
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  keys = {
    {
      "<leader>a+",
      function()
        local tree_ext = require("avante.extensions.nvim_tree")
        tree_ext.add_file()
      end,
      desc = "Select file in NvimTree",
      ft = "NvimTree",
    },
    {
      "<leader>a-",
      function()
        local tree_ext = require("avante.extensions.nvim_tree")
        tree_ext.remove_file()
      end,
      desc = "Deselect file in NvimTree",
      ft = "NvimTree",
    },
  },
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    --- mcphub start
    -- system_prompt as function ensures LLM always has latest MCP server state
    -- This is evaluated for every message, even in existing chats
    system_prompt = function()
      local hub = require("mcphub").get_hub_instance()
      return hub and hub:get_active_servers_prompt() or ""
    end,
    -- Using function prevents requiring mcphub before it's loaded
    custom_tools = function()
      return {
        require("mcphub.extensions.avante").mcp_tool(),
      }
    end,
    --- mcphub end
    mode = "agentic", -- Switch from "agentic" to "legacy"
    selector = {
      exclude_auto_select = { "NvimTree" },
      provider = "snacks",
    },
    -- provider = "moonshot",
    provider = "zai",
    behaviour = {
      -- enable_fastapply = true,
      -- auto_suggestions = true,
      auto_approve_tool_permissions = true,
      -- Example: auto_approve_tool_permissions = {"bash", "str_replace", "grep"}, -- Auto-approve specific tools only
    },
    acp_providers = {
      ["gemini-cli"] = {
        command = "gemini",
        args = { "--experimental-acp" },
        env = {
          NODE_NO_WARNINGS = 1,
        },
      },
    },
    providers = {
      openai = {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-4o", -- your desired model (or use gpt-4o, etc.)
        timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
        extra_request_body = {
          temperature = 0,
          max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
          --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
        },
      },
      zai = {
        __inherited_from = "openai",
        api_key_name = "Z_AI_API_KEY",
        endpoint = "https://api.z.ai/api/coding/paas/v4",
        model = "glm-4.7",
      },
      moonshot = {
        use_ReAct_prompt = true,
        model = "kimi-k2-turbo-preview",
      },
      kimi = {
        __inherited_from = "openai",
        api_key_name = "MOONSHOT_API_KEY",
        endpoint = "https://api.moonshot.ai/v1",
        model = "kimi-k2-0905-preview",
        -- extra_request_body = {
        --   temperature = 0.5,
        --   max_tokens = 262144,
        -- },
      },
      g_pro = {
        __inherited_from = "gemini",
        model = "gemini-3-pro-preview",
      },
      g_flash = {
        __inherited_from = "gemini",
        model = "gemini-3-flash-preview",
      },
      ds_reasoner = {
        __inherited_from = "openai",
        api_key_name = "DEEPSEEK_API_KEY",
        endpoint = "https://api.deepseek.com",
        model = "deepseek-reasoner",
        disable_tools = true,
      },
      ds_chat = {
        __inherited_from = "openai",
        api_key_name = "DEEPSEEK_API_KEY",
        endpoint = "https://api.deepseek.com",
        model = "deepseek-chat",
        disable_tools = true,
      },
      uni_opus4 = {
        __inherited_from = "openai",
        api_key_name = "UNI_API_KEY",
        endpoint = "https://hk.uniapi.io/v1/",
        model = "claude-opus-4-20250514",
      },
      uni_opus41 = {
        __inherited_from = "openai",
        api_key_name = "UNI_API_KEY",
        endpoint = "https://hk.uniapi.io/v1/",
        model = "claude-opus-4-1-20250805",
      },
      uni_sonnet4 = {
        __inherited_from = "openai",
        api_key_name = "UNI_API_KEY",
        endpoint = "https://hk.uniapi.io/v1/",
        model = "claude-sonnet-4-20250514",
      },
      uni_k2 = {
        __inherited_from = "openai",
        api_key_name = "UNI_API_KEY",
        endpoint = "https://hk.uniapi.io/v1/",
        model = "kimi-k2-0711-preview",
      },
      uni_g25_pro = {
        __inherited_from = "openai",
        api_key_name = "UNI_API_KEY",
        endpoint = "https://hk.uniapi.io/v1/",
        model = "gemini-2.5-pro",
      },
      uni_g25_flash = {
        __inherited_from = "openai",
        api_key_name = "UNI_API_KEY",
        endpoint = "https://hk.uniapi.io/v1/",
        model = "gemini-2.5-flash",
      },
      -- uni_ = {
      --   __inherited_from = "openai",
      --   api_key_name = "UNI_API_KEY",
      --   endpoint = "https://hk.uniapi.io/v1/",
      --   model = "",
      -- },
      groq_qwq = {
        __inherited_from = "openai",
        api_key_name = "GROQ_API_KEY",
        endpoint = "https://api.groq.com/openai/v1/",
        model = "qwen-qwq-32b",
        extra_request_body = {
          max_tokens = 32768, -- remember to increase this value, otherwise it will stop generating halfway
        },
        disable_tools = true,
      },
      or_dsv3 = {
        __inherited_from = "openai",
        endpoint = "https://openrouter.ai/api/v1",
        api_key_name = "OPENROUTER_API_KEY",
        model = "deepseek/deepseek-chat-v3-0324:free",
      },
      or_dsr1 = {
        __inherited_from = "openai",
        endpoint = "https://openrouter.ai/api/v1",
        api_key_name = "OPENROUTER_API_KEY",
        model = "deepseek/deepseek-r1:free",
      },
      morph = {
        model = "auto",
      },
    },
    web_search_engine = {
      provider = "serpapi", -- tavily, serpapi, searchapi, google, kagi, brave, or searxng
      proxy = nil, -- proxy support, e.g., http://127.0.0.1:7890
    },
    windows = {
      position = "smart",
      height = 46,
      wrap = true,
      sidebar_header = { align = "center" },
      ask = { floating = false },
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    { "echasnovski/mini.pick", config = true }, -- for file_selector provider mini.pick
    "folke/snacks.nvim",
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = { file_types = { "markdown", "Avante" } },
      ft = { "markdown", "Avante" },
    },
  },
})

-- mcp
-- https://github.com/ravitemer/mcphub.nvim
loong.add_plugin("ravitemer/mcphub.nvim", {
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
  config = function()
    require("mcphub").setup({
      port = 3001,
      shutdown_delay = 0,
      extensions = {
        -- ref: https://ravitemer.github.io/mcphub.nvim/extensions/avante.html#configure-avante-integration
        avante = { make_slash_commands = true },
      },
    })
  end,
})
