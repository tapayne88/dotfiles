--!nonstrict
-- /define <word>: definitions from the local dictd (WordNet + Wiktionary),
-- queried through the dict CLI that the NixOS dictionary module installs and
-- points at localhost via /etc/dict.conf.
--
-- Rows: one per sense, titled with the word, subtitle "n · first clause".
-- Activating a row opens the detail panel with the full text.
--
-- Noctalia enforces a small CPU budget per script callback, and the budget
-- shrinks further on a busy or throttled machine, so the keystroke path only
-- scans and extracts — no block-level cleaning. Full template stripping
-- happens once per word, lazily, when the panel is first opened for it.

local shared = require './shared.luau'

local PANEL_ID = 'tpayne/dict:dict'

local MIN_QUERY = 2
local MAX_ROWS = 30
local MAX_CLAUSE = 90 -- characters of definition shown in a row
local MAX_STDOUT = 512 * 1024 -- truncate absurdly large dict output
local MAX_BLOCKS = 10 -- blocks examined per lookup
local MAX_PARSE_CHARS = 48 * 1024 -- dict output parsed per lookup
local MAX_BLOCK_CHARS = 16 * 1024 -- per-block cap on cleaned display text
local MAX_DISPLAY_BLOCKS = 8 -- blocks kept for the panel (matches panel's MAX_SECTIONS)
local MAX_DISPLAY_LINES = 80 -- lines kept per block for the panel view
local CACHE_LIMIT = 40 -- words kept in the lookup cache

local POS_NAMES = {
  n = 'noun',
  v = 'verb',
  adj = 'adjective',
  adv = 'adverb',
  s = 'satellite',
}

local cache = {} -- word -> lookup entry { word, rows, blocks, display }
local cacheOrder = {} -- FIFO of cache keys, for the bound
local current = nil -- lookup entry behind the rows on screen

local function cacheStore(word, entry)
  if cache[word] == nil then
    table.insert(cacheOrder, word)
  end
  cache[word] = entry
  while #cacheOrder > CACHE_LIMIT do
    cache[table.remove(cacheOrder, 1)] = nil
  end
end

-- WordNet blocks list senses as "adj 1: ..." lines; later senses repeat just
-- the number ("      2: ...") and wrapped continuations sit underneath at a
-- deeper indent, so this walks the raw lines. The headword line comes first
-- and falls through the "last == nil" guard.
local function wordnetSenses(block)
  local senses = {}
  local last = nil
  local pos = nil
  local function addSense(text)
    last = { pos = pos or 'n', text = {} }
    table.insert(senses, last)
    local t = shared.stripTemplates(text)
    if t ~= '' then
      table.insert(last.text, t)
    end
  end
  for _, raw in ipairs(block.lines) do
    local p, text = raw:match '^%s*([%a]+)%s+%d+:%s*(.*)$'
    if p and POS_NAMES[p] then
      pos = p
      addSense(text)
    else
      local num, text = raw:match '^%s+(%d+):%s*(.*)$'
      if num and pos then
        addSense(text)
      elseif last and raw:match '^%s+%S' then
        local t = shared.stripTemplates(raw)
        if t ~= '' then
          table.insert(last.text, t)
        end
      end
    end
  end
  return senses
end

-- Wiktionary blocks carry "English" / "Noun" section headers and
-- "1. definition" lines. Rows need only each definition's first clause, so
-- this scans raw lines and strips templates on the few lines it shows —
-- never the whole block. A definition's wrapped continuation lines are
-- joined (up to three) until the clause can close.
local function wiktionaryRows(word, block, bi, rows, badge)
  local count = 0
  for li, raw in ipairs(block.lines) do
    if #rows >= MAX_ROWS then
      return
    end
    -- Sense numbers are 1-2 digits; historical dates inside quotations
    -- ("1754. [http://…]") must not become rows. Wiktionary sub-items
    -- ("#", "#*", "#:") are quotations and nested senses, not definitions.
    local num, text = raw:match '^%s*(%d%d?)%.%s+(.*)$'
    if num and text:sub(1, 1) ~= '#' then
      local full = shared.stripTemplates(text)
      local j = li + 1
      while
        full ~= ''
        and full:find '[;.]%s' == nil
        and full:find '[;.]%s*$' == nil
        and j <= li + 3
        and j <= #block.lines
      do
        local nextRaw = block.lines[j]
        local nxt = shared.stripTemplates(nextRaw)
        local stopped = nxt == ''
          or nxt:sub(1, 1) == '*'
          or nxt:sub(1, 1) == '#'
          or nextRaw:match '^%s*%d%d?%.%s'
          or shared.isSectionHeader(nxt)
        if stopped then
          break
        end
        full = full .. ' ' .. nxt
        j = j + 1
      end
      if full ~= '' then
        count = count + 1
        table.insert(rows, {
          id = 'def-' .. bi .. '-' .. count,
          title = word,
          subtitle = count .. ' · ' .. shared.firstClause(full, MAX_CLAUSE),
          badge = badge,
        })
      end
    end
  end
end

local function buildEntry(word, stdout)
  local blocks = shared.parseBlocks(stdout, MAX_BLOCKS, MAX_PARSE_CHARS)
  local rows = {}
  for bi, block in ipairs(blocks) do
    if #rows >= MAX_ROWS then
      break
    end
    local short = (block.db or ''):lower()
    if short:find('wordnet', 1, true) then
      local senses = wordnetSenses(block)
      for i, sense in ipairs(senses) do
        if #rows >= MAX_ROWS then
          break
        end
        local text = table.concat(sense.text, ' ')
        if text ~= '' then
          table.insert(rows, {
            id = 'wn-' .. bi .. '-' .. i,
            title = word,
            subtitle = i .. ' · ' .. shared.firstClause(text, MAX_CLAUSE),
            badge = 'wn',
          })
        end
      end
    else
      local badge = short:find('wiktionary', 1, true) and 'wikt' or nil
      wiktionaryRows(word, block, bi, rows, badge)
      if #rows == 0 and bi == 1 then
        table.insert(rows, {
          id = 'block-' .. bi,
          title = word,
          subtitle = '(open for full text)',
          glyph = 'book',
        })
      end
    end
  end
  return { word = word, rows = rows, blocks = blocks, display = nil }
end

-- Full text for the panel: synonym markers lifted to their own lines,
-- templates stripped per block. Runs once per word, on activation.
local function buildDisplay(entry)
  local display = {}
  for _, block in ipairs(entry.blocks or {}) do
    if #display >= MAX_DISPLAY_BLOCKS then
      break
    end
    local rawText = table.concat(block.lines, '\n')
    local rawSize = #rawText
    local cleaned = shared.stripBlockLines({ shared.liftSyns(rawText) }, MAX_BLOCK_CHARS)
    local objs = {}
    local headwordSkipped = false
    for _, line in ipairs(cleaned) do
      if #objs >= MAX_DISPLAY_LINES then
        break
      end
      if line:sub(1, 2) == '\001 ' then
        local syn = shared.trim(line:sub(2))
        if syn ~= '' then
          table.insert(objs, { text = '', syn = syn })
        end
      elseif not headwordSkipped and line:lower() == entry.word:lower() then
        -- Skip the headword line; the panel header already shows the word.
        headwordSkipped = true
      else
        -- Unterminated templates (truncated, badly nested) can survive
        -- stripping; cut the fragment, keep any readable prefix.
        local text = line
        local residue = text:find('{{', 1, true)
        if residue then
          text = shared.trim(text:sub(1, residue - 1))
        end
        if text ~= '' then
          table.insert(objs, { text = text, syn = nil })
        end
      end
    end
    table.insert(display, {
      label = shared.dbLabel(block),
      lines = objs,
      truncated = #objs >= MAX_DISPLAY_LINES or rawSize > MAX_BLOCK_CHARS,
    })
  end
  return display
end

local function publish(query, entry)
  current = entry
  launcher.setResults(query, entry.rows)
end

local function nomatchEntry(word)
  return {
    word = word,
    rows = { { id = 'nomatch', title = 'No definitions found for “' .. word .. '”', glyph = 'book-off' } },
    blocks = {},
    display = {},
  }
end

function onQuery(text)
  local word = shared.trim(text)
  if #word < MIN_QUERY then
    current = nil
    launcher.setResults(text, {
      {
        id = 'hint',
        title = word == '' and 'Type a word to define' or 'Keep typing — two or more characters',
        glyph = 'book',
      },
    })
    return
  end

  local hit = cache[word]
  if hit then
    publish(text, hit)
    return
  end

  launcher.setResults(text, { { id = 'loading', title = 'Looking up “' .. word .. '”…', glyph = 'loader' } })

  -- Argument-array form: no shell parsing of the word, and phrases keep
  -- their spaces (dict joins argv, so it must arrive as one argument).
  noctalia.runAsync({ 'dict', '-f', '--', word }, function(result)
    local entry
    if result.exitCode == 20 then
      entry = nomatchEntry(word)
    elseif result.exitCode ~= 0 then
      entry = {
        word = word,
        rows = {
          {
            id = 'error',
            title = "Couldn't reach dictd — is the dictionary module enabled?",
            glyph = 'alert-triangle',
          },
        },
        blocks = {},
        display = {},
      }
    else
      local stdout = result.stdout or ''
      if #stdout > MAX_STDOUT then
        stdout = stdout:sub(1, MAX_STDOUT)
      end
      entry = buildEntry(word, stdout)
      if #entry.rows == 0 then
        entry = nomatchEntry(word)
      end
    end
    cacheStore(word, entry)
    publish(text, entry)
  end)
end

function onActivate(id)
  if not current or id == 'hint' or id == 'loading' or id == 'nomatch' or id == 'error' then
    return
  end
  if current.display == nil then
    current.display = buildDisplay(current)
  end
  noctalia.state.set('lookup', { word = current.word, display = current.display })
  noctalia.togglePanel(PANEL_ID)
end
