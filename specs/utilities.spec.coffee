utilities = require '../src/replacer'

describe 'replacing require with files', ->
  beforeEach ->
    utilities.clearFilelist()

  it 'can replace require', ->
    input = "require('specs/testFile');"
    expect(utilities.replaceRequires(input)).toContain("worked")

  it 'can replace multiple requires', ->
    input = """
            require('specs/testFile');
            require('specs/testFile3');
            """
    actual = utilities.replaceRequires input
    expect(actual).toContain('worked')
    expect(actual).toContain('worked3')

  it 'can handle multiple files in 1 require', ->
    input = "require('specs/testFile', 'specs/testFile2');"
    actual = utilities.replaceRequires(input)
    expect(actual).toContain 'worked'
    expect(actual).toContain 'worked2'

  it 'preserves what is before and after require', ->
    input = "test;
             require('specs/testFile'); tset"
    actual = utilities.replaceRequires(input)
    expect(actual).toContain 'test'
    expect(actual).toContain 'tset'

  it 'does not eat the semicolon before the require', ->
    input = """funcCall();
               require('specs/testFile');
            """
    actual = utilities.replaceRequires(input)
    expect(actual).toContain 'funcCall();'

  it 'can handle nested requires', ->
    input = "require('specs/testRequire');"
    expect(utilities.replaceRequires(input)).toContain 'At the bottom'

  it 'only includes each file once', ->
    input = """
            require('specs/testFile');
            require('specs/testFile');
            """

    expect(utilities.replaceRequires(input)).toBe '"worked";'
