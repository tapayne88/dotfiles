local index = require 'mason-registry.index'
local Pkg = require 'mason-core.package'
local npm = require 'mason-core.managers.npm'

index['tsun'] = 'tap.mason-registry.tsun'

return Pkg.new {
  name = 'tsun',
  desc = [[TSUN, a TypeScript Upgraded Node, supports a REPL and interpreter for TypeScript]],
  homepage = 'https://www.npmjs.com/package/tsun',
  categories = { Pkg.Cat.Runtime },
  languages = { Pkg.Lang.TypeScript, Pkg.Lang.JavaScript },
  install = npm.packages {
    'tsun',
    bin = { 'tsun' },
  },
}
