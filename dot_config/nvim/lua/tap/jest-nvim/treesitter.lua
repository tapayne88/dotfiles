local utils = require 'tap.jest-nvim.utils'

--- Find child that passes predicate, limiting depth
---@param node Node
---@param predicate fun(node: Node)
---@param max_depth? number|nil
---@return Node|nil
local function find_in_children(node, predicate, max_depth)
  max_depth = max_depth or 5

  if max_depth == 0 then
    return nil
  end

  for child_node in node:iter_children() do
    if predicate(child_node) then
      return child_node
    end

    local ret = find_in_children(child_node, predicate, max_depth - 1)
    if ret ~= nil then
      return ret
    end
  end

  return nil
end

--- Return node if it has child test node
---@param node Node
---@param buf number
---@return string[]
local get_test_expression = function(node, buf)
  local target_text = { 'test', 'it', 'describe' }

  if node:type() ~= 'call_expression' then
    return nil
  end

  local child_test_node = find_in_children(node, function(child_node)
    return child_node:type() == 'identifier'
      and vim.tbl_contains(target_text, vim.treesitter.get_node_text(child_node, buf))
  end, 1)

  return child_test_node ~= nil and node or nil
end

--- Collect selected data from all parent nodes
---@param node Node
---@param buf number
---@param root Node
---@param selector fun(node: Node, buf: number): Node
---@param acc Node[]
---@return Node[]
local function find_in_ancestors(node, buf, root, selector, acc)
  if root == node then
    return acc
  end

  local target_node = selector(node, buf)
  if target_node ~= nil then
    table.insert(acc, target_node)
  end

  return find_in_ancestors(node:parent(), buf, root, selector, acc)
end

--- Get all parent test nodes for cursor position
---@param buf number
---@param cursor number[]
---@return Node[]
local get_test_nodes_from_cursor = function(buf, cursor)
  local line = cursor[1] - 1
  local col = cursor[2]

  local parser = vim.treesitter.get_parser(buf, require('nvim-treesitter.parsers').ft_to_lang(vim.bo.filetype), {})
  local ret
  parser:for_each_tree(function(tree)
    if ret then
      return
    end
    local root = tree:root()
    if root then
      local node = root:descendant_for_range(line, col, line, col)
      ret = find_in_ancestors(node, buf, root, get_test_expression, {})
    end
  end)
  return ret
end

--- Get test strings of test nodes
---@param nodes Node[]
---@param buf number
---@return string
local get_pattern_from_test_nodes = function(nodes, buf)
  local test_strings = vim.tbl_map(function(node)
    local str_node = find_in_children(node, function(child_node)
      -- TODO: handle variables as test strings
      return child_node:type() == 'string'
    end, 3)

    if str_node == nil then
      utils.notify("couldn't find child string of test node", vim.log.levels.WARN)
      return ''
    end

    return vim.treesitter.get_node_text(str_node:child(1), buf)
  end, nodes)

  return table.concat(utils.tbl_reverse(test_strings), ' ')
end

local M = {}

--- Get test string for cursor position
---@return string
function M.get_nearest_pattern()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(vim.fn.win_getid())
  local test_nodes = get_test_nodes_from_cursor(bufnr, cursor)

  if #test_nodes == 0 then
    return nil
  end

  return get_pattern_from_test_nodes(test_nodes, bufnr)
end

return M
