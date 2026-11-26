--!nonstrict
-- Detail panel for /define lookups: the word up top, then one section per
-- dictionary with the full (template-stripped) definition text. The
-- launcher entry builds the cleaned, capped display lazily on first
-- activation; synonym lists arrive as their own line objects and render
-- dimmed next to their sense.

local shared = require './shared.luau'

local MAX_SECTIONS = 8
local MAX_SECTION_LINES = 60

local isOpen = false

local function textNode(t)
  local isQuote = t:sub(1, 1) == '*'
  if isQuote then
    t = t:gsub('^%*%s*:?%s*', '')
    if t == '' then
      return nil
    end
  end
  if shared.isSectionHeader(t) then
    return ui.label { text = t, fontSize = 13, fontWeight = 'bold', color = 'primary' }
  end
  return ui.label {
    text = t,
    fontSize = 13,
    color = isQuote and 'on_surface/0.7' or 'on_surface',
    baseline = 'textFixedHeight',
  }
end

local function synNode(syn)
  return ui.label {
    text = '→ syn: ' .. syn,
    fontSize = 12,
    color = 'primary/0.8',
    baseline = 'textFixedHeight',
  }
end

local function render(lookup)
  if not lookup or lookup.word == nil then
    panel.render(ui.column({ padding = 16 }, {
      ui.label { text = 'Look up a word with /define in the launcher first.', color = 'on_surface/0.8' },
    }))
    return
  end

  local word = lookup.word
  local sections = {}
  for si, section in ipairs(lookup.display or {}) do
    if si > MAX_SECTIONS then
      table.insert(
        sections,
        ui.label {
          text = '+' .. (#lookup.display - MAX_SECTIONS) .. ' more dictionaries',
          color = 'on_surface/0.6',
        }
      )
      break
    end

    local body = {}
    for i, line in ipairs(section.lines or {}) do
      if #body >= MAX_SECTION_LINES then
        break
      end
      if line.text ~= '' then
        local node = textNode(line.text)
        if node then
          table.insert(body, node)
        end
      end
      if line.syn then
        table.insert(body, synNode(line.syn))
      end
    end
    if section.truncated then
      table.insert(body, ui.label { text = '…', color = 'on_surface/0.6' })
    end
    if #body == 0 then
      table.insert(body, ui.label { text = 'No text.', color = 'on_surface/0.6' })
    end

    local children = {
      ui.label { text = section.label, fontSize = 13, fontWeight = 'bold', color = 'primary' },
    }
    for _, node in ipairs(body) do
      table.insert(children, node)
    end
    table.insert(sections, ui.column({ key = 'section-' .. si, gap = 4 }, children))
  end
  if #sections == 0 then
    table.insert(sections, ui.label { text = 'No definitions found.', color = 'on_surface/0.6' })
  end

  panel.render(ui.column({ padding = 16, gap = 12 }, {
    ui.row({ gap = 10, align = 'center' }, {
      ui.glyph { name = 'book', size = 22, color = 'primary' },
      ui.label { text = word, fontSize = 20, fontWeight = 'bold' },
      ui.spacer { flexGrow = 1 },
      ui.button { glyph = 'x', variant = 'ghost', controlSize = 'sm', onClick = 'onCloseClicked' },
    }),
    ui.separator { color = 'on_surface/0.2' },
    ui.scroll({ gap = 14, flexGrow = 1 }, sections),
  }))
end

function onOpen()
  isOpen = true
  render(noctalia.state.get 'lookup')
end

function onClose()
  isOpen = false
end

function onCloseClicked()
  panel.close()
end

noctalia.state.watch('lookup', function(lookup)
  if isOpen then
    render(lookup)
  end
end)
