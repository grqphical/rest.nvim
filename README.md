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

### Saving requests or responses

If you have a request or a response you wish to save to a file simply run `:RestSave`, optionally add a file path and rest
will save the contents of the current request/response to a file
