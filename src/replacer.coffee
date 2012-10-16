fs = require 'fs'
path = require 'path'
{parser, uglify} = require 'uglify-js'

filesSeen = {}
recurseDeeper =
  toplevel: true
  stat: true

preprocessFuncs =
  require: (args) ->
    output = []
    for file in args
      fullPath = path.resolve file
      if !filesSeen[fullPath]
        filesSeen[fullPath] = true
        data = fs.readFileSync(fullPath, 'utf-8')
        output.push exports.replaceRequires(data)
    output.join '\n'

getNextFunction = (parsedInput) ->
  if typeof parsedInput[0] == 'string'
    if parsedInput[0] == 'call'
      if typeof preprocessFuncs[parsedInput[1][1]] == 'function'
        args = []
        for argArray of parsedInput[2]
          args.push parsedInput[2][argArray][1]

        return parser.parse(preprocessFuncs[parsedInput[1][1]](args))
    else if recurseDeeper[parsedInput[0]]
      parsedInput[1] = getNextFunction parsedInput[1]
  else
    for key of parsedInput
      parsedInput[key] = getNextFunction parsedInput[key]

  parsedInput

exports.clearFilelist = ->
  filesSeen = {}

exports.addFileToList = (file) ->
  filesSeen[file] = true

exports.replaceRequires = (input) ->
  uglify.gen_code getNextFunction parser.parse input
