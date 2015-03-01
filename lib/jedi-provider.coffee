exec = require('child_process').exec;
path = require 'path'


module.exports =
class JediProvider
  id: 'autocomplete-plus-jedi'
  selector: '.source.python'
  providerblacklist: null

  constructor: ->
    @providerblacklist =
      'autocomplete-plus-fuzzyprovider': '.source.python'
      'autocomplete-plus-symbolprovider': '.source.python'

  requestHandler: (options) ->
    return new Promise (resolve) ->
      suggestions = []

      # get current text
      text = options.buffer.cachedText
      row = options.cursor.getBufferPosition().row
      column = options.cursor.getBufferPosition().column

      escaped = text.replace(/'/g, "''")

      projectPath = atom.project.getPath()

      # completion scripts expects 4 arguments: text, current line, column and project path
      # TODO: this breaks when a docstring uses '''
      command = "python " + __dirname + "/jedi-complete.py '" + escaped + "' " + row + " " + column + " " + projectPath

      exec command, (error, stdout, stderr) ->
        resolve(suggestions) unless stdout != ""
        resolve(suggestions) unless stderr != ""
        resolve(suggestions) unless error != null

        jediResponse = JSON.parse stdout
        
        # get prefix
        lines = text.split "\n"
        line = lines[row]

        # generate a list of potential prefixes
        indexes = []
        indexes.push line.substr(line.lastIndexOf(" ") + 1)
        indexes.push line.substr(line.lastIndexOf("(") + 2)
        indexes.push line.substr(line.lastIndexOf(".") + 1)

        # sort array by string length - shortest element is the prefix
        prefix = indexes.sort((a, b) ->
          a.length - b.length
        )[0]

        # build suggestions
        for index of jediResponse
          label = jediResponse[index].description

          if label.length > 80
            label = label.substr(0, 80)

          suggestions.push({
            word: jediResponse[index].name,
            prefix: prefix,
            label: label
          })

        resolve(suggestions)
