utilities = require '../src/replacer'

describe 'replacing require with files', ->
  beforeEach ->
    utilities.clearFilelist()

  it 'can replace require', ->
    input = "require('bin/deploy/specs/testFile');"
    expect(utilities.replaceRequires(input)).toContain("worked")

  it 'can replace multiple requires', ->
    input = """
            require('bin/deploy/specs/testFile');
            require('bin/deploy/specs/testFile3');
            """
    actual = utilities.replaceRequires input
    expect(actual).toContain('worked')
    expect(actual).toContain('worked3')

  it 'can handle multiple files in 1 require', ->
    input = "require('bin/deploy/specs/testFile', 'bin/deploy/specs/testFile2');"
    actual = utilities.replaceRequires(input)
    expect(actual).toContain 'worked'
    expect(actual).toContain 'worked2'

  it 'preserves what is before and after require', ->
    input = "test;
             require('bin/deploy/specs/testFile'); tset"
    actual = utilities.replaceRequires(input)
    expect(actual).toContain 'test'
    expect(actual).toContain 'tset'

  it 'does not eat the semicolon before the require', ->
    input = """funcCall();
               require('bin/deploy/specs/testFile');
            """
    actual = utilities.replaceRequires(input)
    expect(actual).toContain 'funcCall();'

  it 'can handle nested requires', ->
    input = "require('bin/deploy/specs/testRequire');"
    expect(utilities.replaceRequires(input)).toContain 'At the bottom'

  it 'only includes each file once', ->
    input = """
            require('bin/deploy/specs/testFile');
            require('bin/deploy/specs/testFile');
            """

    expected = "//require('bin/deploy/specs/testFile');\nworked\n//endRequire;\n\n"
    expect(utilities.replaceRequires(input)).toBe expected

  it 'delimites the requires with comments', ->
    input = 'require("bin/deploy/specs/testFile");'
    actual = utilities.replaceRequires(input)
    expect(actual).toContain "//require('bin/deploy/specs/testFile');"
    expect(actual).toContain "//endRequire;"
