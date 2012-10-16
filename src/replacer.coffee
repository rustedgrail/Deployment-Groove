fs = require 'fs'
path = require 'path'
parser = require('uglify-js').parser

filesSeen = {}
recurseDeeper =
  'toplevel': true
  'stat': true

getNextFunction = (parsedInput) ->
  if typeof parsedInput[0] == 'string'
    if parsedInput[0] == 'call'
      args = []
      for argArray of parsedInput[2]
        args.push parsedInput[2][argArray][1]
      console.log "#{parsedInput[1][1]} called with #{args}"
    else if recurseDeeper[parsedInput[0]]
      getNextFunction parsedInput[1]
  else
    getNextFunction parsedInput[0]

exports.clearFilelist = ->
  filesSeen = {}

exports.addFileToList = (file) ->
  filesSeen[file] = true

exports.replaceRequires = (input) ->
  getNextFunction parser.parse input

  requireRegex = /^\s*require\((.*?)\);/gm
  input.replace requireRegex, (match, p1, offset, string) ->
    output = []
    files = p1.match(/[^'",\s]+/g)
    for file in files
      fullPath = path.resolve file
      if !filesSeen[fullPath]
        filesSeen[fullPath] = true
        data = fs.readFileSync(fullPath, 'utf-8')
        output.push "//require('#{file}');\n"
        output.push "#{exports.replaceRequires(data)}"
        output.push "//endRequire;\n"
    output.join ''
