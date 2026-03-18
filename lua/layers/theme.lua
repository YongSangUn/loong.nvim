local loong = require("core.loong")

loong.add_plugin("tanvirtin/monokai.nvim", {
  lazy = false,
  priority = 1000,
  config = function()
    -- https://github.com/tanvirtin/monokai.nvim#configuration
    local monokai = require("monokai")
    monokai.setup({
      custom_hlgroups = {
        ["@comment"] = { fg = "#5C8C4A", italic = true },
      },
    })
    vim.api.nvim_set_hl(0, "FoldColumn", { link = "Normal" })
  end,
})
