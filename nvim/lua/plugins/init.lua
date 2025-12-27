local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require("config.set")

require("lazy").setup({
    spec = {
        -- lsp
        {
            "mason-org/mason.nvim",
            opts = {}
        },

        {
            "neovim/nvim-lspconfig",
            dependencies = {
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-path",
                "hrsh7th/cmp-cmdline",
                "hrsh7th/nvim-cmp",
            },
            config = require("plugins.lsp"),
            ft = { "cpp", "c", "cmake", "bash", "yaml", "lua", "json", "glsl" }
        },

        {
            "mason-org/mason-lspconfig.nvim",
            opts = {
                automatic_enable = true,
                ensure_installed = {
                    "cmake",
                    "clangd",
                    "lua_ls",
                },
            },
            dependencies = {
                "mason-org/mason.nvim",
                "neovim/nvim-lspconfig",
            },
        },

        -- misc
        {
            "folke/snacks.nvim",
            priority = 1000,
            lazy = false,

            ---@type snacks.Config
            opts = {
                picker = { enabled = true },
            }
        },

        -- treesitter
        {
            "nvim-treesitter/nvim-treesitter",
            branch = "master",
            lazy = false,
            build = ":TSUpdate",
            opts = {
                ensure_installed = { "cpp", "c", "glsl", "json", "yaml", "cmake", "lua" },
            },
            config = function()
                require("nvim-treesitter.configs").setup({
                    ensure_installed = { "c", "glsl", "cpp", "glsl", "yaml", "bash", "cmake", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
                    sync_install = false,
                    auto_install = true,
                    highlight = {
                        enable = true,
                        disable = function(lang, buf)
                            local max_filesize = 100 * 1024 -- 100 KB
                            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                            if ok and stats and stats.size > max_filesize then
                                return true
                            end
                        end,
                        additional_vim_regex_highlighting = true,
                    },
                })
            end,
        },

        -- telescope
        {
            "nvim-telescope/telescope.nvim",
            tag = "0.1.8",
            dependencies = { "nvim-lua/plenary.nvim" }
        },

        -- harpoon (mwah)
        {
            "theprimeagen/harpoon",
        },

        -- theme
        {
            "catppuccin/nvim",
            name = "catppuccin",
            priority = 1000,
            opts = {
                flavour = "mocha",
            },
        },

        -- keymapping
        {
            "folke/which-key.nvim",
        },

        -- git
        {
            "tpope/vim-fugitive",
        },

        -- status line
        {
            "nvim-lualine/lualine.nvim",
            dependencies = {
                "folke/tokyonight.nvim",
                "catppuccin/nvim",
                "echasnovski/mini.icons",
                "stevearc/overseer.nvim",
            },
            config = function()
                local lualine = require("lualine")
                local overseer = require("overseer")

                lualine.setup({
                    options = {
                        theme = "tokyonight",
                    },
                    sections = {
                        lualine_x = {
                            "overseer",
                        },
                    },
                    extensions = {
                        "overseer",
                    },
                })
            end,
        },

        -- discord rpc
        {
            "andweeb/presence.nvim",
            event = "VeryLazy",
            config = function()
                local presence = {
                    auto_update = true,
                    neovim_image_text = "nyoravim",
                    main_image = "neovim",
                    log_level = nil,
                    show_time = false,
                    enable_line_number = false,
                    buttons = true,

                    editing_text = "editing %s",
                    file_explorer_text = "browsing %s",
                    git_commit_text = "committing",
                    plugin_manager_text = "managing plugins",
                    reading_text = "viewing %s",
                    workspace_text = "working on %s",
                    line_number_text = "%s/%s",
                }

                require("presence").setup(presence)
            end,
        },
    },

    install = { colorscheme = { "catppuccin" } },
    checker = { enabled = true },
})
