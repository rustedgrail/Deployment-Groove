fs = require 'fs'
path = require 'path'

replacer = require './replacer'

readFile = (file) ->
  fullPath = path.resolve file
  if !replacer.seenFile(fullPath)
    replacer.addFileToList(fullPath)
    data = fs.readFileSync(fullPath, 'utf-8')
    replacer.replaceRequires(data)

exports.require = (args) ->
    output = []
    for file in args
      output.push readFile file
    output.join '\n'
