module.exports =
  editorSubscription: null
  providers: []
  autocomplete: null

  activate: ->
    atom.packages.activatePackage('autocomplete-plus').then (pkg) =>
      @autocomplete = pkg.mainModule
      return unless @autocomplete?
      Provider = (require './jedi-provider').ProviderClass(@autocomplete.Provider, @autocomplete.Suggestion)
      return unless Provider?
      @editorSubscription = atom.workspace.observeTextEditors((editor) => @registerProvider(Provider, editor))

  registerProvider: (Provider, editor) ->
    return unless Provider?
    return unless editor?
    editorView = atom.views.getView(editor)
    return unless editorView?
    if not editorView.mini
      provider = new Provider(editor)
      @autocomplete.registerProviderForEditor(provider, editor)
      @providers.push(provider)

  deactivate: ->
    @editorSubscription?.dispose()
    @editorSubscription = null

    @providers.forEach (provider) => @autocomplete.unregisterProvider(provider)
    @providers = []
