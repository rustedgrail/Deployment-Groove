fs = require 'fs'
path = require 'path'
acorn = require 'acorn'

filesSeen = {}

getInnerTree = (parsedInput) ->
  if parsedInput.type == 'Program'
    for statement in parsedInput.body
      if statement.expression.type == 'CallExpression' &&
         statement.expression.callee.name == 'require'
           for value in statement.expression.arguments
             console.log value.value

exports.clearFilelist = ->
  filesSeen = {}

exports.addFileToList = (file) ->
  filesSeen[file] = true

exports.replaceRequires = (input) ->
  getInnerTree acorn.parse input
    
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
