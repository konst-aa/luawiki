# Luawiki
My favorite parts of [Vimwiki](https://github.com/vimwiki/vimwiki) + other stuff I come up with

As of 2024-09-06 I no longer use Vimwiki. It was a great ride

### Features:
- Keybinds for creating and following links


### Installation:
Install using your preferred nvim package manager.


Then, `require("luawiki").setup {}` in your `init.lua`.

Note: this plugin is unfortunately incompatible with [vim-autopairs](https://github.com/jiangmiao/auto-pairs), so I recommend using [nvim-autopairs](https://github.com/windwp/nvim-autopairs)

### Usage and customization
#### Keybinds:

- `Enter` (on a link) -> follow the link, opening the file in a new buffer
- `Enter` (on a word) -> create a link to `word.md`
- `Backspace` -> Go to previous/parent link. NOTE: This shortcut doesn't close the buffer left behind
- `Shift-Enter` (on a todo line that starts with `- [ ]`) -> check item off
- same thing but for a checked-off item -> uncheck it
- `Shift-Enter` (in normal mode, at an empty line) -> create todolist entry, and go into insert mode
- `Enter` (in insert mode, at an empty todolist entry) -> clears the line

#### Configuring:
There is effectively nothing to configure.

### Considering:
- [ ] jumping between wiki links with tab
- [ ] qol shortcuts like `<leader>day` for printing a formatted date under the cursor
- [ ] pandoc & friends
- [ ] appropriate configurability for ^^
- [ ] per-filetype abstractions
- [ ] renaming (low prio, I will probably use regex for this)
- [ ] And, of course, any feature requests

