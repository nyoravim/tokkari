return function()
    local dap = require("dap")
    dap.adapters.codelldb = {
        type = "executable",
        command = os.getenv("HOME") .. "/codelldb/extension/adapter/codelldb",
    }

    dap.adapters.cppdbg = {
        type = "executable",
        id = "cppdbg",
        command = "/home/nora/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
    }

    -- throw eggs at me
    -- i cant break vscode dependency
    require("dap.ext.vscode").load_launchjs()
end
