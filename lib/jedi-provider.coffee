exec = require('child_process').exec;

module.exports =
  selector: '.source.py,'
  blacklist: '.source.py .comment'

  requestHandler: (options) ->
    return new Promise (resolve) ->
      suggestions = []

      # get current text
      text = options.buffer.cachedText
      row = options.cursor.getBufferPosition().row
      column = options.cursor.getBufferPosition().column

      escaped = text.replace(/'/g, "''")

      # completion scripts expects 3 arguments: text, current line and column
      # TODO: this breaks when a docstring uses '''
      command = "python " + __dirname + "/jedi-complete.py '" + escaped + "' " + row + " " + column

      exec command, (error, stdout, stderr) ->
        resolve(suggestions) unless stdout != ""

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
          suggestions.push({
            word: jediResponse[index].name,
            prefix:prefix,
            label: jediResponse[index].description
          })

        resolve(suggestions)

  loaded: ->
    return
