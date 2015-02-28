provider = require './jedi-provider'

module.exports =
  activate: -> provider.loaded()
  getProvider: -> providers: [provider]
