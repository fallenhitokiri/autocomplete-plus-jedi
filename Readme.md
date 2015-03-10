# autocomplete-plus-jedi - Adding jedi based completions for Python to autocomplete-plus

## Installation
Either use Atoms package manager or `apm install autocomplete-plus-jedi`

## Usage
APJ - let us just call it APJ, that's way shorter - uses the Python interpreter
in your path. If you want to use it with a virtualenv just make sure the env is
active and start atom from the command line.

Right now the completion daemon is started on port 7777 - please make sure no
other service is using this port. In the next release the port will be configurable.

#### Warning
This addon is young and not feature complete. But it is under active
development, so eventually things will improve.


## Changelog

2015-03-10 Timo Zimmermann <timo@screamingatmyscreen.com>

  - add daemon to provide jedi completion results
