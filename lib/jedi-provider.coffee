{$} = require 'atom'


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

      payload =
        source: text
        line: row
        column: column

      $.ajax
        url: 'http://127.0.0.1:7777'
        type: 'POST'
        data: JSON.stringify payload

        success: (data) ->
          # get prefix
          regex = /[a-z|A-Z|_0-9-]+$/
          prefix = options.prefix.match(regex)?[0] or ''

          # build suggestions
          for index of data
            label = data[index].description

            if label.length > 80
              label = label.substr(0, 80)

            suggestions.push({
              word: data[index].name,
              prefix: prefix,
              label: label
            })

          resolve(suggestions)

        error: (data) ->
          console.log "Error communicating with server"
          console.log data
