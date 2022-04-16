--- Inspired by @tjdevries' astraunauta.nvim/ @TimUntersberger's config / @akinsho's config
--- store all callbacks in one global table so they are able to survive re-requiring this file
_TapGlobalCallbacks = _TapGlobalCallbacks or {}

_G.tap = {_store = _TapGlobalCallbacks, mappings = {}}

function tap._create(f)
    table.insert(tap._store, f)
    return #tap._store
end

function tap._execute(id, ...) tap._store[id](...) end

--- Check if neovim version is nightly
function tap.neovim_nightly()
    local nightly = '0.8'
    local version = vim.version()
    return string.format('%i.%i', version.major, version.minor) == nightly
end

--- Allow calling of unsafe functions like require in the critical loading path
function tap.safe_call(fn)
    local success, value = pcall(fn)
    return success and value or nil
end

