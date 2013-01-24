escodegen = require 'escodegen'
parser = require 'esprima'

preprocessFuncs = require './preprocessors'

filesSeen = {}
recurseDeeper =
  Program: 'body'

variables = {}

handleExpression = (expressionStatement) ->
  expression = expressionStatement.expression
  if expression.type == 'CallExpression'
    if typeof preprocessFuncs[expression.callee.name] == 'function'
      args = []
      retValue = []
      for argument in expression.arguments
        if argument.type == 'Identifier'
          args.push variables[argument.name]
        else if argument.type == 'Literal'
          args.push argument.value
        else
          args.push argument
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
      variables[declaration.id.name] = declaration.init.value
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
  temp = traverseTree(parser.parse(input))
  escodegen.generate temp
