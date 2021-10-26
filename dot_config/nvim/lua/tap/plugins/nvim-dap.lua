local dap = require('dap')

if vim.env.DAP_DEBUG then
    dap.set_log_level('DEBUG')
    print("DAP debug log: " .. vim.fn.stdpath('cache') .. "/dap.log")
end

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
    command = 'node',
    args = {
        '--require', 'ts-node/register',
        adapter_location .. '/vscode-node-debug2/out/src/nodeDebug.js'
    },
    options = {
        -- env = {"TS_NODE_PROEJCT=" .. vim.fn.getcwd() .. "/tsconfig-server.json"},
        cwd = vim.fn.getcwd()
    }
}

dap.configurations.javascript = {
    {
        type = 'node2',
        request = 'launch',
        name = 'node something',
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
        name = 'ts-node inspect',
        program = '${workspaceFolder}/${file}',
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        protocol = 'inspector',
        console = 'integratedTerminal'
    }
}
