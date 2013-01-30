escodegen = require 'escodegen'
parser = require 'esprima'

preprocessFuncs = require './preprocessors'

variables = {}
filesSeen = {}
recurseDeeper =
  Program: 'body'

handleBinaryExpression = (binaryStatement) ->
  statement = escodegen.generate binaryStatement
  eval "with (#{JSON.stringify(variables)}) {#{statement}}"

valueTypes =
  Identifier: (arg) -> variables[arg.name]
  Literal: (arg) -> arg.value
  BinaryExpression: handleBinaryExpression

getVal = (value) ->
  valueTypes[value.type](value)

handleExpression = (expressionStatement) ->
  expression = expressionStatement.expression
  if expression.type == 'CallExpression'
    if typeof preprocessFuncs[expression.callee.name] == 'function'
      args = []
      retValue = []
      for argument in expression.arguments
        args.push getVal argument
      for expression in parser.parse(preprocessFuncs[expression.callee.name](args)).body
        retValue.push expression
      return retValue
  expressionStatement

traverseTree = (parsedInput) ->
  if Array.isArray(parsedInput)
    newInput = []
    for expression in parsedInput
      newExpression = traverseTree expression
      if Array.isArray(newExpression)
        for newLine in newExpression
          newInput.push newLine
      else
        newInput.push newExpression
    return newInput
  else if parsedInput.type == 'ExpressionStatement'
    return handleExpression(parsedInput)
  else if parsedInput.type == 'VariableDeclaration'
    for declaration in parsedInput.declarations
      variables[declaration.id.name] = getVal(declaration.init)
  else if recurseDeeper[parsedInput.type]
    parsedInput[recurseDeeper[parsedInput.type]] = traverseTree parsedInput[recurseDeeper[parsedInput.type]]

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
  temp = traverseTree parser.parse input
  escodegen.generate temp
