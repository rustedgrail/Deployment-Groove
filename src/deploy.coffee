fs = require 'fs'
utilities = require('./utilities')
path = require 'path'
parser = require('./parser.js')
options = parser.options

readFunc = (filename) ->
  utilities.addFileToList path.resolve filename
  utilities.replaceRequires "#{fs.readFileSync(filename, 'utf-8')}\n", options.preprocessor

if options.lint
  oldRead = readFunc
  readFunc = (filename) ->
    utilities.hint filename
    oldRead filename

output = "//#{JSON.stringify options}\n"

for file in options.files
  output += readFunc file

if options.output
  stream = fs.createWriteStream options.output, {flags: 'w'}
else
  stream = process.stdout

options.writeFunction output, stream
