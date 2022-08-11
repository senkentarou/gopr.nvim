# gopr.nvim
* Git open pull request (gopr) plugin for neovim.

## Installation
* [vim-plug](https://github.com/junegunn/vim-plug)

```
Plug 'senkentarou/gopr.nvim'
```

## Setup
* Please set your nvim confg before use.
```
require('gopr').setup {}
```

* For customizing, please setup as below,
```
require('gopr').setup {
  remote_base_url = 'github.com',
  default_remote = 'origin'
}
```

## Usage
* Please execute `:Gopr` command on target line, then [github](https://github.com/) page is opened following commit hash on your web browser.
* You could set your git remote as an argument like `:Gopr upstream`

## For development
* Load under development plugin files on root repository.
  * (If you already installed this plugin thankfully, please comment out applying code before.)

```
nvim --cmd "set rtp+=."
```

## License
* MIT
