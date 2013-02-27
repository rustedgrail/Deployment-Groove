fs = require 'fs'
path = require 'path'
handlebars = require 'handlebars'

replacer = require './replacer'
handlebarsIncluded = false

readFile = (file) ->
  fullPath = path.resolve file
  if !replacer.seenFile(fullPath)
    replacer.addFileToList(fullPath)
    fs.readFileSync(fullPath, 'utf-8')
  else
    ''

exports.require = (files) ->
  output = []
  for file in files
    data = readFile file
    output.push replacer.replaceRequires data
  output.join '\n'

includeHandlebars = ->
  handlebarsIncluded = true
  exports.require ['bin/libs/handlebars/lib/runtime.js']

exports.template = (files) ->
  output = []

  if !handlebarsIncluded and not files[0] == "false"  
    output.push includeHandlebars()

  output.push('(function() {\n  var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};\n')
  for file in files
    fullPath = path.join "#{__dirname}/../..", file
    continue if !fs.existsSync fullPath
    data = readFile file
    template = path.basename file, '.html'

    output.push "templates['#{template}'] = template(#{handlebars.precompile(data)});\n"

  output.push '})();'
  output.join ''
