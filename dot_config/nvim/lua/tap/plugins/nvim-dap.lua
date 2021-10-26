local dap = require('dap')

local adapter_location = os.getenv("XDG_DATA_HOME") .. "/nvim-dap/adapters"

-- Need to install the adapater manually
-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#javascript
dap.adapters.node2 = {
    type = 'executable',
    command = 'node',
    args = {adapter_location .. '/vscode-node-debug2/out/src/nodeDebug.js'}
}
dap.adapters.ts_node2 = {
    type = 'executable',
    command = 'yarn run ts-node',
    args = {adapter_location .. '/vscode-node-debug2/out/src/nodeDebug.js'}
}

dap.configurations.javascript = {
    {
        type = 'node2',
        request = 'launch',
        program = '${workspaceFolder}/${file}',
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        protocol = 'inspector',
        console = 'integratedTerminal'
    }
}
dap.configurations.typescript = {
    {
        type = 'ts_node2',
        request = 'launch',
        program = '${workspaceFolder}/${file}',
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        protocol = 'inspector',
        console = 'integratedTerminal'
    }
}
