fs = require 'fs'
path = require 'path'
glob = require 'glob'
CSON = require 'season'
rimraf = require 'rimraf'

run = (root='./') ->
  topModulesPath = path.resolve path.join root, 'node_modules'

  # moved from deep lvl to the root
  moved = []

  # target already existed; uknown/incompatible version, kept location
  skipped = []

  # target already existed; same version, removed
  duplicates = []

  longest = ''

  compareVersions = (pOne, pTwo) ->
    fromP = path.join(pOne, "package.json")
    toP = path.join(pTwo, "package.json")
    if fs.existsSync(fromP) and fs.existsSync(toP)

      # compare versions
      try
        fromPackage = CSON.readFileSync(fromP)
        toPackage = CSON.readFileSync(toP)
        console.log fromPackage.version, toPackage.version
        if fromPackage.version is toPackage.version
          console.log "Removing", pOne
          duplicates.push path.basename(pOne)
          rimraf.sync pOne
          return -2
      catch err
        console.log err
    console.log "Skipping", pOne
    skipped.push path.basename(pOne)
    if pOne.length > longest.length
      longest = pOne
    -1

  moveIfPossible = (from, to) ->
    return  unless fs.existsSync(from)
    if fs.existsSync(to)

      # del `from` if `to` satisfies `from`s "parent" package.json
      compareVersions from, to
    else

      # move if `to` does NOT exist
      moved.push path.basename(from)
      fs.renameSync from, to

  if fs.existsSync(topModulesPath)
    console.log "to:", topModulesPath
    console.log "cwd:", process.cwd()

    # cwd: topModulesPath
    files = glob.sync "./node_modules/**/node_modules/*", {cwd: root}
    if files.length > 0
      files.reverse() # start moving folders from deepest to more shallow
      # console.log(files);
      console.log files.length, "deps"

      for file in files
        depName = path.basename(file)
        moveIfPossible path.join(root, file), path.join(topModulesPath, depName)

        # remove node_modules IF empty
        try
          # rmdir does not delete non empty folders
          fs.rmdirSync path.dirname(file)

      console.log '\nMoved (to the topmost \'node_modules\' folder):', moved.length, '\n', moved.sort().join(', '),
      '\n\nSkipped (different versions):', skipped.length, '\n', skipped.sort().join(', '),
      '\n\nDuplicates (same versions, removed):', duplicates.length, '\n', duplicates.sort().join(', ')

      console.log '\nLongest path:', longest
      console.log '\nEffective chars:', longest.length - root.length

module.exports = run
