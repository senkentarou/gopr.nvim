# gopr.nvim
* Git open pull request (gopr) plugin for neovim.

## Installation
* [vim-plug](https://github.com/junegunn/vim-plug)

```
Plug 'senkentarou/gopr.nvim'
```

## Usage
* Please execute `:Gopr` command on target line, then [github](https://github.com/) page is opened following commit hash on your web browser.

## For development
* Load under development plugin files on root repository.
  * (If you already installed this plugin thankfully, please comment out applying code before.)

```
nvim --cmd "set rtp+=."
```

## License
* MIT
