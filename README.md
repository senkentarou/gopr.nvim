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
  default_remote = 'origin'
}
```

## Usage
* Please execute `:Gopr` command on target line, then [github](https://github.com/) page is opened following commit hash on your web browser.
* You could set your git remote as an argument like `:Gopr upstream`
* Just open commit diff, please execute `:Gocd` command on target line. (and so you can reach pull request on github manually)

## For development
* Load under development plugin files on root repository.
  * (If you already installed this plugin thankfully, please comment out applying code before.)

```
nvim --cmd "set rtp+=."
```

## License
* MIT
