{parser, uglify} = require 'uglify-js'

preprocessFuncs = require './preprocessors'

filesSeen = {}
recurseDeeper =
  toplevel: true
  stat: true

traverseTree = (parsedInput) ->
  if typeof parsedInput[0] == 'string'
    if parsedInput[0] == 'call'
      if typeof preprocessFuncs[parsedInput[1][1]] == 'function'
        args = []
        for argArray of parsedInput[2]
          args.push parsedInput[2][argArray][1]

        return parser.parse(preprocessFuncs[parsedInput[1][1]](args))
    else if recurseDeeper[parsedInput[0]]
      parsedInput[1] = traverseTree parsedInput[1]
  else
    for key of parsedInput
      parsedInput[key] = traverseTree parsedInput[key]

  parsedInput

exports.clearFilelist = ->
  filesSeen = {}

exports.addFileToList = (file) ->
  filesSeen[file] = true

exports.seenFile = (file) ->
  filesSeen[file]

exports.replaceRequires = (input, preprocessor) ->
  if preprocessor
    preprocessFuncs = require "#{process.cwd()}/#{preprocessor}"
  uglify.gen_code(traverseTree(parser.parse(input)), beautify: true)
