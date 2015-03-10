cp = require 'child_process'
JediProvider = require './jedi-provider'

module.exports =
  provider: null
  jediServer: null

  activate: ->
    if !@jediServer
      projectPath = atom.project.getPath()
      command = "python " + __dirname + "/jedi-complete.py '" + projectPath + "'"

      @jediServer = cp.exec command

    @provider = new JediProvider()

  deactivate: ->
    @jediServer.kill()

  getProvider: ->
    return {providers: [@provider]}
