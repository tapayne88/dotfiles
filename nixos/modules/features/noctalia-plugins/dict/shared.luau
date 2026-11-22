--!nonstrict
-- Shared helpers for the Dict plugin's launcher and panel entries.
--
-- Noctalia kills script callbacks that exceed a small CPU budget, measured
-- in CPU time on whatever core the worker gets. On a throttled or busy
-- laptop that budget shrinks several-fold, so keystroke lookups only scan
-- and extract; full template cleaning happens once per word, lazily, when
-- the detail panel is first opened for it.

local M = {}

function M.trim(s)
  return (s:match '^%s*(.-)%s*$')
end

-- Remove {{wiki|templates}}; the second pass only runs when nesting remains.
local function stripAll(s)
  local stripped = s:gsub('%{%{[^{}]*%}%}', '')
  if stripped:find('{{', 1, true) then
    local prev
    repeat
      prev = stripped
      stripped = stripped:gsub('%{%{[^{}]*%}%}', '')
    until stripped == prev
  end
  return stripped
end

function M.stripTemplates(s)
  return M.trim(stripAll(s):gsub('[ \t]+', ' '))
end

-- Clean a whole block at once: templates wrap across dictd's 72-column line
-- breaks, so per-line stripping cannot close them. The input is truncated
-- BEFORE stripping so a single pathological block cannot blow the callback
-- budget, and whitespace is collapsed globally rather than per line.
-- Returns trimmed, non-empty lines.
function M.stripBlockLines(lines, maxChars)
  local text = table.concat(lines, '\n')
  if maxChars and #text > maxChars then
    text = text:sub(1, maxChars)
    local lastNl = text:find '\n[^\n]*$'
    if lastNl then
      text = text:sub(1, lastNl - 1)
    end
  end
  text = stripAll(text)
  -- Truncation may leave an unterminated template at the end; drop it.
  text = text:gsub('%{%{[^{}]*$', '')
  text = text:gsub('[ \t]+', ' ')
  text = text:gsub('\n[ \t]+', '\n')
  text = text:gsub('[ \t]+\n', '\n')
  text = text:gsub('^%s+', '')
  local out = {}
  for line in (text .. '\n'):gmatch '(.-)\n' do
    if line ~= '' then
      table.insert(out, line)
    end
  end
  return out
end

-- `dict -f` prints "host<TAB>port<TAB>db<TAB>description" headers, one per
-- definition block, with the block's body lines in between. Headers start
-- non-blank and body lines always arrive indented, so a byte check skips
-- the header match for almost every line. maxBlocks/maxChars stop the scan
-- early: two-letter queries can still return dozens of huge blocks, and the
-- launcher only ever shows the first few.
function M.parseBlocks(stdout, maxBlocks, maxChars)
  local blocks = {}
  local cur = nil
  local bodyChars = 0
  for line in stdout:gmatch '([^\n]*)\n?' do
    local c = line:byte(1)
    if c ~= nil and c ~= 32 then
      local db, dbFull = line:match '^%S+\t%d+\t(%S+)\t(.*)$'
      if db then
        if maxBlocks and #blocks >= maxBlocks then
          break
        end
        cur = { db = db, dbFull = dbFull, lines = {} }
        table.insert(blocks, cur)
      elseif cur then
        table.insert(cur.lines, line)
      end
    elseif cur then
      table.insert(cur.lines, line)
    end
    if cur and maxChars then
      bodyChars = bodyChars + #line
      if bodyChars > maxChars then
        break
      end
    end
  end
  for _, block in ipairs(blocks) do
    while #block.lines > 0 and M.trim(block.lines[#block.lines]) == '' do
      table.remove(block.lines)
    end
  end
  return blocks
end

function M.dbLabel(block)
  local full = block.dbFull or ''
  if full ~= '' and full ~= 'unknown' then
    return full
  end
  local short = (block.db or ''):lower()
  if short:find('wiktionary', 1, true) then
    return 'Wiktionary'
  elseif short:find('wordnet', 1, true) then
    return 'WordNet'
  end
  return block.db or 'Dictionary'
end

-- Lines like "English", "Noun", or "Proper noun" are section headers,
-- not prose. Punctuation rules them out of definition sentences.
function M.isSectionHeader(text)
  return text:match '^%u[%l%s]+$' ~= nil
end

-- First clause of a definition: text up to the first ; or . that closes a
-- clause, hard-capped so rows stay one line. Occasional early cuts on
-- abbreviations ("U.S.") are accepted.
function M.firstClause(text, maxChars)
  local cut = text:find '[;.]%s' or text:find '[;.]%s*$'
  local clause = cut and text:sub(1, cut - 1) or text
  clause = M.trim(clause)
  if maxChars and #clause > maxChars then
    clause = M.trim(clause:sub(1, maxChars)) .. '…'
  end
  return clause
end

-- Lift synonym lists out of definition text before cleaning: WordNet's
-- "[syn: {a}, {b}]" markers (which can wrap across lines) and Wiktionary's
-- "{{syn|lang|a|b}}" templates both become \001-prefixed lines, so they
-- survive template stripping and land as their own display lines.
function M.liftSyns(text)
  text = text:gsub('%[syn:%s*([^%]]*)%]', function(names)
    local out = {}
    for name in names:gmatch '{([^{}]*)}' do
      table.insert(out, (name:gsub('_', ' ')))
    end
    if #out == 0 then
      return ''
    end
    return '\n\001 ' .. table.concat(out, ', ')
  end)
  text = text:gsub('%{%{syn|[^|]*|([^}]*)%}%}', function(rest)
    local out = {}
    for raw in rest:gmatch '[^|]+' do
      local name = M.trim(raw)
      if name ~= '' and name:sub(1, 10) ~= 'Thesaurus:' then
        table.insert(out, name)
      end
    end
    if #out == 0 then
      return ''
    end
    return '\n\001 ' .. table.concat(out, ', ')
  end)
  return text
end

return M
