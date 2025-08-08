# rest.nvim

A simple HTTP client for Neovim that you edit like a buffer

## Installation

**NOTE:** rest.nvim requires you to have curl installed and added to your PATH

### vim.pack (Neovim 0.12+)

```lua
vim.pack.add({ src = "https://github.com/grqphical/rest.nvim" })
```

### lazy.nvim

```lua
{
    "grqphical/rest.nvim",
}
```

## Usage

To create a new request, run the command `:NewRequest`. This will open a new empty buffer where you can start
writing out the parameters of your request. Below is an example of a request:
```
url: https://httpbin.org/post
method: POST
header: Content-Type: application/json
body: {"foo":"bar"}
```

You can read more about the `rest.nvim` request language on the wiki

To send the request, simply write the buffer with `:w` and the HTTP response will appear in a new buffer

### Sending files

Since `rest.nvim` is a frontend for curl, you can send entire files in the body of a request with:
```
body: @file.txt
```

### Saving requests or responses

If you have a request or a response you wish to save to a file simply run `:RestSave`, optionally add a file path and rest
will save the contents of the current request/response to a file

## Configuration

If you wish to configure `rest.nvim` use the code below:
```lua
require("rest").setup {
    default_method = "GET",
    default_body = "",
    default_http_version = "HTTP/1.1"
    default_header = {}
}

```
These are the default options that `rest.nvim` comes with

## Roadmap

This is a plugin I built to serve my own needs but if you feel that you can write an improvement to my code feel
free to make a PR

These are some of the features I want to implement

- [ ] Shorthand tags for markup langage (u instead of url)

- [ ] Request template in config

## License

`rest.nvim` is licensed under the MIT License
