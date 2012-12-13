args = require('optimist').argv
utilities = require './utilities'

switches = [
  ['-o', '--output FILENAME', 'Output file for concatenated files']
  , ['-u', '--uncompressed', 'Do not minify or gzip the output']
  , ['-l', '--lint', 'Lint the files and output the results']
]

options =
  output: args.output || args.o
  files: args._
  lint: args.lint || args.l
  writeFunction: if args.uncompressed || args.u then utilities.uncompressedWrite else utilities.minifiedWrite
  preprocessor: args.preprocessor || args.p

exports.options = options
