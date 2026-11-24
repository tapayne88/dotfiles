--!nonstrict
-- /define <word>: definitions from the local dictd (WordNet), queried through
-- the dict CLI that the NixOS dictionary module installs and points at
-- localhost via /etc/dict.conf.
--
-- Rows: one per WordNet sense, titled with the word, subtitle "n · first
-- clause". Activating any row opens the detail panel with the full text.
--
-- Noctalia kills script callbacks that exceed a small CPU budget, and the
-- budget shrinks further on a busy or throttled machine. WordNet responses
-- are ~1 KB, so the whole lookup - rows and the panel's display text - is
-- built in one cheap pass, and activation only stashes and opens the panel.

local shared = require './shared.luau'

local PANEL_ID = 'tpayne/dict:dict'

local MIN_QUERY = 2
local MAX_ROWS = 30
local MAX_CLAUSE = 90 -- characters of definition shown in a row
local MAX_STDOUT = 512 * 1024 -- truncate absurdly large dict output
local MAX_BLOCKS = 10 -- blocks examined per lookup
local MAX_PARSE_CHARS = 48 * 1024 -- dict output parsed per lookup
local MAX_BLOCK_CHARS = 16 * 1024 -- per-block cap on cleaned display text
local MAX_DISPLAY_BLOCKS = 8 -- blocks kept for the panel view
local MAX_DISPLAY_LINES = 80 -- lines kept per block for the panel view
local CACHE_LIMIT = 40 -- words kept in the lookup cache

local POS_NAMES = {
  n = 'noun',
  v = 'verb',
  adj = 'adjective',
  adv = 'adverb',
  s = 'satellite',
}

local cache = {} -- word -> lookup entry { word, rows, display }
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

-- One lookup: WordNet sense rows plus the panel's cleaned display text.
local function buildEntry(word, stdout)
  local blocks = shared.parseBlocks(stdout, MAX_BLOCKS, MAX_PARSE_CHARS)
  local rows = {}
  local display = {}

  for bi, block in ipairs(blocks) do
    local label = shared.dbLabel(block)
    local short = (block.db or ''):lower()
    local isWordNet = short:find('wordnet', 1, true) ~= nil

    -- Rows: WordNet senses only; any other database gets a single row that
    -- simply leads to the panel.
    if isWordNet then
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
    elseif #rows < MAX_ROWS then
      table.insert(rows, {
        id = 'db-' .. bi,
        title = word,
        subtitle = label .. ' entry',
        glyph = 'book',
      })
    end

    -- Display for the panel: synonym markers lifted, templates stripped,
    -- headword skipped. Capped per block so even a future heavyweight
    -- database cannot blow the callback budget.
    if #display < MAX_DISPLAY_BLOCKS then
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
        elseif not headwordSkipped and line:lower() == word:lower() then
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
        label = label,
        lines = objs,
        truncated = #objs >= MAX_DISPLAY_LINES or rawSize > MAX_BLOCK_CHARS,
      })
    end

    if #rows >= MAX_ROWS and #display >= MAX_DISPLAY_BLOCKS then
      break
    end
  end

  return { word = word, rows = rows, display = display }
end

local function publish(query, entry)
  current = entry
  launcher.setResults(query, entry.rows)
end

local function nomatchEntry(word)
  return {
    word = word,
    rows = { { id = 'nomatch', title = 'No definitions found for “' .. word .. '”', glyph = 'book-off' } },
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
    -- dict exits 20 (word) or 21 (phrase) when nothing matched.
    if result.exitCode == 20 or result.exitCode == 21 then
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
  noctalia.state.set('lookup', current)
  noctalia.togglePanel(PANEL_ID)
end
