return function()
    local remap = require("config.remap")

    local function on_lsp_attach(client, buf)
        remap.on_lsp_attach(client, buf)

        -- nano has other stuff. uh...
    end

    -- kind of hacky
    local prev_start = vim.lsp.start
    vim.lsp.start = function(config, opts)
        local prev_on_attach = config.on_attach
        if not prev_on_attach then
            config.on_attach = on_lsp_attach
        else
            config.on_attach = function (client, buf)
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

    local cmp = require("cmp")
    cmp.setup({
        mapping = remap.cmp,
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "buffer" },
        }),
    })
end
