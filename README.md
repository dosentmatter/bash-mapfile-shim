# *bash-mapfile-shim*

**bash-mapfile-shim** is a shim for the `mapfile` command in bash versions 4+.
Currently, only options `-d` and `-t` are supported.

## Usage

source mapfile.bash in your `.bashrc` and use the `mapfile` function.
`mapfile` will use the existing `mapfile` command on bash 4+.

You can also call the function directly by calling `mapfile_function`.
It should behave like the `mapfile` command.
Currently, only options `-d` and `-t` are supported.

There is also an unused `mapfile_IFS` function that isn't used by the shim.
It works similar to word splitting where empty lines are not included
in the array if DELIM is whitespace (space, tab, newline) or null.
