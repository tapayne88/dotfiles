--- Inspired by @tjdevries' astraunauta.nvim/ @TimUntersberger's config / @akinsho's config
--- store all callbacks in one global table so they are able to survive re-requiring this file
_TapGlobalCallbacks = _TapGlobalCallbacks or {}

_G.tap = {_store = _TapGlobalCallbacks}

function tap._create(f)
    table.insert(tap._store, f)
    return #tap._store
end

function tap._execute(id, ...) tap._store[id](...) end
