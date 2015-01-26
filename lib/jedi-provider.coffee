path = require 'path'
sh = require 'execsyncs'

module.exports =
ProviderClass: (Provider, Suggestion, dispatch)  ->
  class JediProvider extends Provider
    exclusive: true

    buildSuggestions: ->
      return if @isPython() is false
      return if @shouldNotComplete() is true
      suggestions = []
      @findSuggestions(suggestions)
      return suggestions

    findSuggestions: (suggestions) ->
      text = @editor.buffer.cachedText
      row = @editor.getCursor().getBufferPosition().row
      column = @editor.getCursor().getBufferPosition().column

      escaped = text.replace(/'/g, "''")

      # completion scripts expects 3 arguments: text, current line and column
      # TODO: this breaks when a docstring uses '''
      command = "python " + __dirname + "/jedi-complete.py '" + escaped + "' " + row + " " + column

      response = "" + sh command
      return unless response != ""

      jedi = JSON.parse response
      prefix = @getPrefix()

      for index of jedi
        suggestions.push(new Suggestion(this, word: jedi[index].name, prefix:prefix, label: jedi[index].description))

    isPython: ->
      fileName = path.basename @editor.getBuffer().getPath()

      # fileName can be undefined if we are in a popover e.x.
      if fileName == undefined
        return false

      found = fileName.indexOf(".py", fileName.length - 3)

      if found != -1
        return true

      return false

    shouldNotComplete: ->
      text = @editor.buffer.cachedText
      row = @editor.getCursor().getBufferPosition().row
      column = @editor.getCursor().getBufferPosition().column

      lines = text.split "\n"
      line = lines[row]

      # do not complete after a colon
      if line.indexOf(":") != -1
        index = line.lastIndexOf(":")
        index = index + 1
        return true if index == column

      # do not complete comments
      if line.indexOf("#") != -1
        index = line.indexOf("#")
        double = line.indexOf("\"")
        single = line.indexOf("'")

        # if we find a sharp and no quotes, do not complete
        return true if double == -1 and single == -1

        # complete if the sharp character is between quotation marks
        if double != -1
          rdouble = line.lastIndexOf("\"")
          console.log double < index < rdouble
          return false if double < index < rdouble

        # complete if the sharp character is between single quotation marks
        if single != -1
          rsingle = line.lastIndexOf("'")
          return false if single < index < rsingle

      return false

    getPrefix: ->
      text = @editor.buffer.cachedText
      row = @editor.getCursor().getBufferPosition().row
      column = @editor.getCursor().getBufferPosition().column

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

      return prefix
