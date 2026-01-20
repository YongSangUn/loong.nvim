local loong = require("core.loong")

vim.lsp.enable(loong.lsp_enabled)

-- commands
vim.api.nvim_create_user_command("LspInfo", ":checkhealth lsp", { desc = "Check Lsp Health" })

-- diagnostics
vim.diagnostic.config({
  -- virtual_text = true,
  -- virtual_lines = true,
  virtual_text = false,
  update_in_insert = true,
  severity_sort = true,
  float = {
    max_width = 80,
    warp = true,
    severity_sort = true,
    source = true,
    border = "rounded",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
})

vim.api.nvim_create_autocmd("CursorHold", {
  pattern = "*",
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false })
  end,
})

-- LspAttach
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspAttach", {}),
  callback = function(ev)
    -- rename
    vim.keymap.set("n", "<leader>ln", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Lsp: Rename" })

    -- definitions
    vim.keymap.set("n", "<leader>ld", function()
      local params = vim.lsp.util.make_position_params(0, "utf-8")
      vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result, _, _)
        if not result or vim.tbl_isempty(result) then
          vim.notify("No definition found", vim.log.levels.INFO)
        else
          require("snacks").picker.lsp_definitions()
        end
      end)
    end, { buffer = ev.buf, desc = "Lsp: Go to Definition" })

    -- references
    vim.keymap.set("n", "<leader>lr", function()
      require("snacks").picker.lsp_references()
    end, { buffer = ev.buf, desc = "Lsp: Find References" })
  end,
})

-- lsp installer
-- https://github.com/mason-org/mason.nvim
loong.add_plugin("mason-org/mason.nvim", {
  opts = {
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
    },
  },
  config = function(_, opts)
    require("mason").setup(opts)
    local mr = require("mason-registry")
    -- ref https://github.com/adibhanna/nvim/blob/main/lua/plugins/mason.lua
    local function install_pkg()
      -- vim.notify("Mason: Installing packages...", vim.inspect(loong.ensure_installed))
      for _, pkg in ipairs(loong.ensure_installed) do
        if mr.has_package(pkg) then
          local p = mr.get_package(pkg)
          if not p:is_installed() then
            -- vim.notify("Mason: Installing " .. pkg .. "...", vim.log.levels.INFO)
            p:install():once("closed", function()
              if p:is_installed() then
                vim.notify("Mason: Successfully installed " .. pkg, vim.log.levels.INFO)
              else
                vim.notify("Mason: Failed to install " .. pkg, vim.log.levels.ERROR)
              end
            end)
          end
        end
      end
    end
    if mr.refresh then
      mr.refresh(install_pkg)
    else
      install_pkg()
    end
  end,
})

-- fotmat
-- https://github.com/stevearc/conform.nvim
loong.add_plugin("stevearc/conform.nvim", {
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    {
      "<leader>ff",
      function()
        require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 1000 })
      end,
      desc = "Format File",
      mode = "n",
    },
  },
  opts = {
    default_format_opts = {
      lsp_format = "fallback",
    },
    formatters_by_ft = {
      lua = { "stylua" },
      go = { "goimports", "gofmt" },
      sh = { "shfmt" },
      python = { "isort", "black" },
      markdown = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
      htmldjango = { "prettier" },
      javascript = { "prettier", "eslint_d" },
      typescript = { "prettier", "eslint_d" },
      json = { "prettier" },
      yaml = { "yamlfmt_global" },
      ["azure-pipelines"] = { "yamlfmt_global" },
      -- sql = { "sqlfluff" },
      -- ["*"] = { "codespell" },
      ["_"] = { "trim_whitespace" },
    },
    -- format_on_save = {
    --   lsp_fallback = true,
    --   async = false,
    --   timeout_ms = 500,
    -- },
    formatters = {
      injected = { options = { ignore_errors = true } },
      yamlfmt_global = {
        command = "yamlfmt",
        args = {
          "-formatter",
          "indentless_arrays=true,retain_line_breaks=true,scan_folded_as_literal=true",
          "-in",
        },
      },
    },
  },
})
