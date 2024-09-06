# Luawiki
My favorite parts of [Vimwiki](https://github.com/vimwiki/vimwiki) + other stuff I come up with

As of 2024-09-06 I no longer use Vimwiki. It was a great ride

### Features:
- Keybinds for creating and following links


### Installation:
Install using your preferred nvim package manager.


Then, `require("luawiki")` in your `init.lua`.

### Usage and customization
#### Keybinds:

- `Enter` (on a link) -> follow the link, opening the file in a new buffer
- `Enter` (on a word) -> create a link to `word.md`
- `Backspace` -> Go to previous/parent link. NOTE: This shortcut doesn't close the buffer left behind

#### Configuring:
There is currently nothing to configure.

### Considering:
- [ ] jumping between wiki links with tab
- [ ] qol shortcuts like `<leader>day` for printing a formatted date under the cursor
- [ ] pandoc & friends
- [ ] appropriate configurability for ^^
- [ ] per-filetype abstractions
- [ ] renaming (low prio, I will probably use regex for this)
- [ ] And, of course, any feature requests

