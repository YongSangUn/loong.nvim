local g = vim.g
local opt = vim.opt

-- Make sure to setup `mapleader` and `maplocalleader` before lazy loading
g.mapleader = " "

-- Hint: use `:h <option>` to figure out the meaning if needed
-- https://neovim.io/doc/user/provider.html#g%3Aclipboard
g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = function()
      return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
    end, -- Return the content of the default register inside the current Neovim
    ["*"] = function()
      return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
    end,
  },
}
opt.clipboard:append("unnamedplus")

-- opt.completeopt = { 'menu', 'menuone', 'noselect' }
opt.mouse = "a" -- allow the mouse to be used in Nvim

-- Tab
local indent = 4
opt.tabstop = indent -- number of visual spaces per TAB
opt.softtabstop = indent -- number of spacesin tab when editing
opt.shiftwidth = indent -- insert 4 spaces on a tab
opt.expandtab = true -- tabs are spaces, mainly because of python
opt.autoindent = true -- copt indent when starting new line; delete the indent if not type any

-- show tab char and space
opt.list = true
opt.listchars = "tab:→·,trail:·,nbsp:·"

-- UI config
-- a single global statusline for the current window，
-- pr: https://github.com/neovim/neovim/pull/17266
opt.laststatus = 3
opt.number = true -- show absolute number
opt.relativenumber = true -- add numbers to each line on the left side
opt.cursorline = true -- highlight cursor line underneath the cursor horizontally
opt.splitbelow = true -- open new vertical split bottom
opt.splitright = true -- open new horizontal splits right
-- vim.opt.termguicolors = true        -- enabl 24-bit RGB color in the TUI
-- opt.showmode = false -- we are experienced, wo don't need the "-- INSERT --" mode hint

-- Searching
opt.incsearch = true -- search as characters are entered
opt.hlsearch = true -- do not highlight matches
opt.ignorecase = true -- ignore case in searches by default
opt.smartcase = true -- but make it case sensitive if an uppercase is entered

--- nvim-tree
-- disable netrw
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

--- bufferline
opt.termguicolors = true

--- CursorHold delay, unit in milliseconds, default 4000ms
opt.updatetime = 750

--- Line Break
opt.wrap = true
opt.linebreak = true
opt.breakindent = true
