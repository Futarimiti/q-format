# q-format

Better formatting

## Why not the built-in formatter?

These are the things I hate:
* It clueless accepts any result, even if it's error message
* You always lose your cursor position and your focus after formatting
* Why does formatexpr deserve greater priority than formatprg anyway?

## What has improved
* Formatting will not be applied if a shell error arisen
* Views will be restored after formatting
* You can specify the preference: formatexpr, formatprg, equalprg... on a filetype basis
* You can specify what to do
    * Upon successful formatting, e.g. write to file
    * Upon failed formatting, e.g. show error message
    * At the end of formatting, e.g. `normal! zz`
    * When formatting does not apply

## Installation

```lua
-- lazy.nvim
return
{ 'Futarimiti/q-format'
, branch = 'v2'
, config = function () require('q-format').setup() end
}
```

## Customisation

For complete options, with their type, defaults and descriptions,
see [config/defaults.lua](lua/q-format/config/defaults.lua).

Q-format provides module `q-format.user` which in turn
provides function `format` to format the current buffer,
which can be used to setup keymaps or commands.
Q-format itself does bind any keymaps or commands---I
hate plugins that reach their fingers too far.

```lua
local u = require 'q-format.user'
vim.keymap.set('n', 'Q', u.format)
```

You may also use autocmds to format on save,
mimicking those 'auto-format' plugins,
though I would recommend against it---you
must first see the formatting result before
you can decide whether to keep it, don't you?
