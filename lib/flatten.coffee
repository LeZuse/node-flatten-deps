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
    glob "./node_modules/**/node_modules/*", {cwd: root}, (err, files) ->
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

      console.log('moved', moved, moved.length,
      'skipped', skipped, skipped.length,
      'duplicates', duplicates, duplicates.length);

module.exports = run
