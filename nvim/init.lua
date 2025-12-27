vim.opt.shell = "zsh"

-- load plugins
require("plugins")

-- map keys
require("config.remap").map_keys()

-- set colorscheme
vim.cmd.colorscheme "catppuccin"
