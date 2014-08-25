assert = require 'assert'
fs = require 'fs'
path = require 'path'
CSON = require 'season'
wrench = require 'wrench'

# readAll = (files, opt={cwd:'.'}) ->
#   obj = {}
#   for file, key in files
#     fpath = path.join(opt.cwd, file)
#     if fs.lstatSync(fpath).isDirectory()
#       # create object of files -> contents
#       obj[file] = {}
#       # obj[file] = readAll(files.filter (f) ->
#       #   console.log file
#       #   f.indexOf(file) isnt 0
#       # , {cwd:opt.cwd})
#     else
#       # read contents
#       o = {}
#       o[file] = fs.readFileSync fpath, 'utf8'
#       obj[key] = o
#   obj

describe 'Flatten', ->

  beforeEach ->
    # Our "mock fs"
    wrench.copyDirSyncRecursive './test/mock', './test/_data'

  afterEach ->
    wrench.rmdirSyncRecursive './test/_data'

  it 'module-c versions should equal', ->
    meta1 = JSON.parse fs.readFileSync './test/_data/node_modules/module-c/package.json'
    meta2 = JSON.parse fs.readFileSync './test/_data/node_modules/module-b/node_modules/module-c/package.json'
    assert.equal meta1.version, meta2.version

  it 'should pass test #1', ->
    flatten = require '../lib/flatten'
    # console.log mockFs.readFileSync './node_modules/module-c/package.json', 'utf8'
    flatten './test/_data'
    res = wrench.readdirSyncRecursive './test/_data'
    assert.deepEqual res, [
      'node_modules',
      'package.json',
      'node_modules/module-b',
      'node_modules/module-c',
      'node_modules/module-d', # main version
      'node_modules/module-e',
      'node_modules/module-b/node_modules',
      'node_modules/module-b/package.json',
      'node_modules/module-b/node_modules/module-d',
      'node_modules/module-b/node_modules/module-d/package.json', # different version
      'node_modules/module-c/node_modules',
      'node_modules/module-c/package.json',
      'node_modules/module-c/node_modules/module-d',
      'node_modules/module-c/node_modules/module-d/package.json', # different version
      'node_modules/module-d/package.json',
      'node_modules/module-e/package.json'
    ]

    # res = readAll(res, {cwd: './test/_data'})
    # console.log res



  # A
  # - B - C
  # - C
  config =
    'package.json': JSON.stringify({
      'name': 'module-a'
      'version': '0.1.0'
    })
    'node_modules': {
      'module-b': {
        'package.json': JSON.stringify({
          'name': 'module-a'
          'version': '0.1.0'
        })
        'node_modules': {
          'module-c': {
            'package.json': JSON.stringify({
              'name': 'module-b'
              'version': '0.1.0'
            })
          }
        }
      }
      'module-c': {
        'package.json': JSON.stringify({
          'name': 'module-b'
          'version': '0.1.0'
        })
      }
    }
