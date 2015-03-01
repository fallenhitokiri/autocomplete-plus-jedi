JediProvider = require './jedi-provider'

module.exports =
  provider: null

  activate: ->
  	@provider = new JediProvider()

  getProvider: ->
  	return {providers: [@provider]}
