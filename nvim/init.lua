vim.g.mapleader = " "

vim.opt.shell = "zsh"

vim.opt.nu = true
vim.opt.relativenumber = false

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "100"

vim.cmd("set nofoldenable")

vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        if ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
            pcall(vim.cmd, "TSUpdate")
        end
    end,
})

vim.pack.add({
    -- theme
    { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },

    -- misc
    { src = "https://github.com/folke/snacks.nvim" },

    -- treesitter
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },

    -- telescope
    { src = "https://github.com/nvim-telescope/telescope.nvim",   version = "0.1.8" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },

    -- harpoon (mwah)
    { src = "https://github.com/theprimeagen/harpoon" },

    -- git
    { src = "https://github.com/tpope/vim-fugitive" },

    -- status line
    { src = "https://github.com/nvim-lualine/lualine.nvim" },
    { src = "https://github.com/folke/tokyonight.nvim" },
    { src = "https://github.com/echasnovski/mini.icons" },

    -- lsp + completion
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/hrsh7th/nvim-cmp" },
    { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
    { src = "https://github.com/hrsh7th/cmp-buffer" },
    { src = "https://github.com/hrsh7th/cmp-path" },
    { src = "https://github.com/hrsh7th/cmp-cmdline" },
})

require("catppuccin").setup({
    flavour = "mocha",
})

require("snacks").setup({
    picker = { enabled = true },
})

-- treesitter (main branch: setup() only configures install_dir)
local ts = require("nvim-treesitter")
ts.setup({})

ts.install({
    "c", "cpp", "glsl", "json", "yaml", "cmake", "lua",
    "bash", "vim", "vimdoc", "query", "markdown", "markdown_inline",
    "go", "gomod", "gosum", "gowork", "rust",
})

vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        local buf = args.buf

        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return
        end

        pcall(vim.treesitter.start, buf)
    end,
})

require("lualine").setup({
    options = {
        theme = "tokyonight",
    },
    sections = {
        lualine_x = {},
    },
    extensions = {
        "overseer",
    },
})

-- stealing both nano's and primeagen's keybinds. sorry
-- https://github.com/goolord/nvim - nano's config
local function on_lsp_attach(client, buf)
    local function map(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = buf, silent = true, desc = desc })
    end

    map("<leader>ld", function() vim.diagnostic.open_float(0, { scope = "line" }) end, "Show diagnostics")
    map("K", vim.lsp.buf.hover, "Hover")
    map("g[", vim.diagnostic.goto_prev, "Previous diagnostic")
    map("g]", vim.diagnostic.goto_next, "Next diagnostic")
    map("gd", function() Snacks.picker.lsp_definitions() end, "Go to symbol definition")
    map("<leader>fs", function() Snacks.picker.lsp_workspace_symbols() end, "List workspace symbols")
    map("<leader>lk", vim.lsp.buf.signature_help, "Signature help")
    map("<leader>lR", vim.lsp.buf.rename, "Rename")
    map("<leader>li", function() Snacks.picker.lsp_implementations() end, "Implementation")
    map("<leader>lu", function() Snacks.picker.lsp_references() end, "References")
    map("<leader>lt", function() Snacks.picker.lsp_type_definitions() end, "Type definition")
    map("<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format document")
    map("<C-]>", vim.lsp.buf.definition, "Go to definition")
end

-- kind of hacky: inject on_attach into every LSP client
local prev_start = vim.lsp.start
vim.lsp.start = function(config, opts)
    local prev_on_attach = config.on_attach
    if not prev_on_attach then
        config.on_attach = on_lsp_attach
    else
        config.on_attach = function(client, buf)
            prev_on_attach(client, buf)
            on_lsp_attach(client, buf)
        end
    end
    return prev_start(config, opts)
end

vim.lsp.config("lua_ls", {
    on_attach = function(client, buf)
        runtime_path = vim.split(package.path, ";")
        table.insert(runtime_path, "lua/?.lua")
        table.insert(runtime_path, "lua/?/init.lua")
    end,
    cmd = { "lua-language-server" },
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
                path = runtime_path,
            },
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = {
                enable = false,
            },
        },
    },
})

-- overwrite clangd on_attach
vim.lsp.config("clangd", {
    cmd = {
        "clangd",
        "--header-insertion=never",
    },
})

vim.lsp.enable({ "lua_ls", "clangd", "gopls", "rust_analyzer" })

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
        ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),

        -- disable
        ["<Up>"] = {},
        ["<Down>"] = {},
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "buffer" },
    }),
})

-- vim
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

-- rearrange selection
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- harpoon is the greatest plugin to ever have been written
local harpoon_mark = require("harpoon.mark")
local harpoon_ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>a", harpoon_mark.add_file)
vim.keymap.set("n", "<C-e>", harpoon_ui.toggle_quick_menu)

vim.keymap.set("n", "<C-h>", function() harpoon_ui.nav_file(1) end)
vim.keymap.set("n", "<C-t>", function() harpoon_ui.nav_file(2) end)
vim.keymap.set("n", "<C-n>", function() harpoon_ui.nav_file(3) end)
vim.keymap.set("n", "<C-s>", function() harpoon_ui.nav_file(4) end)

-- telescope
local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>pf", builtin.find_files)
vim.keymap.set("n", "<C-p>", builtin.git_files)
vim.keymap.set("n", "<leader>ps", function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)

vim.cmd.colorscheme("catppuccin")
