-- stealing both nano's and primeagen's keybinds. sorry
-- https://github.com/goolord/nvim - nano's config

export = {}

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }

export.cmp = cmp.mapping.preset.insert({
    ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
    ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),

    -- disable
    ["<Up>"] = {},
    ["<Down>"] = {},
})

function export.on_lsp_attach(client, buf)
    local wk = require("which-key")

    -- https://github.com/goolord/nvim/blob/main/lua/modules/lsp.lua
    wk.add {
        { noremap = true, silent = true, buffer = buf },
        { "<leader>ld", function() vim.diagnostic.open_float(0, { scope = "line" }) end, desc = "Show diagnostics" },
        { "K", vim.lsp.buf.hover, desc = "Hover" },
        { "g[", vim.diagnostic.goto_prev, desc = "Previous diagnostic" },
        { "g]", vim.diagnostic.goto_next, desc = "Next diagnostic" },
        { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Go to symbol definition" },
        { "<leader>fs", function() Snacks.picker.lsp_workspace_symbols() end, desc = "List workspace symbols" },
        { "<leader>l", name = "+LSP" },
        { "<leader>lk", vim.lsp.buf.signature_help, desc = "Signature help" },
        { "<leader>lR", vim.lsp.buf.rename, desc = "Rename" },
        { "<leader>li", function() Snacks.picker.lsp_implementations() end, desc = "Implementation" },
        { "<leader>li", function() Snacks.picker.lsp_references() end, desc = "References" },
        { "<leader>lt", function() Snacks.picker.lsp_type_definitions() end, desc = "Type definition" },
        { "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, desc = "Format document" },
        { "<C-]>", vim.lsp.buf.definition, desc = "Go to definition" }
    }
end

function export.map_keys()
    local wk = require("which-key")
    local mason_lspconfig = require("mason-lspconfig")

    -- vim
    wk.add{{
        { "<leader>pv", vim.cmd.Ex },
        { "<leader>gs", vim.cmd.Git },
    }}

    -- oh god i need these
    wk.add({
        mode = { "v" },
        { "J", ":m '>+1<CR>gv=gv" },
        { "K", ":m '<-2<CR>gv=gv" },
    })

    -- harpoon is the greatest plugin to ever have been written
    local mark = require("harpoon.mark")
    local ui = require("harpoon.ui")

    wk.add({
        { "<leader>a", mark.add_file },
        { "<C-e>", ui.toggle_quick_menu },

        { "<C-h>", function() ui.nav_file(1) end },
        { "<C-t>", function() ui.nav_file(2) end },
        { "<C-n>", function() ui.nav_file(3) end },
        { "<C-s>", function() ui.nav_file(4) end },
    })

    -- telescope
    local ts = require("telescope.builtin")

    wk.add({
        { "<leader>pf", ts.find_files, },
        { "<C-p>", ts.git_files, },
        { "<leader>ps", function()
            ts.grep_string({ search = vim.fn.input("Grep > ") })
        end },
    })

    -- debugging
    local dap = require("dap")

    wk.add({
        { "<leader>db", dap.toggle_breakpoint },
        { "<leader>dc", dap.continue },
        { "<C-Tab>", dap.step_over },
        { "<leader>di", dap.step_into },
        { "<leader>do", dap.step_out },
        { "<leader>dr", dap.repl.open },
        { "<leader>du", dap.up },
        { "<leader>dd", dap.down },
        { "<leader>ds", dap.close },
    })

    -- tasks
    local overseer = require("overseer")

    wk.add({
        { "<C-B>", function() overseer.run_template({ tags = { overseer.TAG.BUILD } }) end },
        { "<leader>to", overseer.open },
        { "<leader>tc", overseer.close },
    })
end

return export
