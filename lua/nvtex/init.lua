local M = {}

-- Plenary
local job = require 'plenary.job'

-- Telescope
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

local default_settings = {
    pdfviewer = "sumatra",
    compiler = "pdflatex"
}

M.state = {
    live_compile = false,
}
function split_once(inputstr, sep)
    local prefix, suffix = inputstr:match("(.-)%s(.+)")
    local t = {}
    table.insert(t, prefix)
    table.insert(t, suffix)
    return t
end

function check_error(line)
    if type(line) ~= "string" then
        return
    end

    if string.sub(line, 1, 1) == '!' then
        print('An error has occured')
    end
end

function M.compile_current_buffer()
    local currentbuffer = vim.api.nvim_buf_get_name(0)

    job:new({
        command = 'pdflatex',
        args = { currentbuffer },
        cwd = './',
        on_stdout = function(j, return_val)
            check_error(return_val)
        end,
    }):start()
end

function M.setup()
    vim.api.nvim_create_user_command("LatexEnableLiveCompile", function()
        M.state.live_compile = true
        print("Live Latex Compilation Enabled")
    end, {})

    vim.api.nvim_create_user_command("LatexDisableLiveCompile", function()
        M.state.live_compile = false
        print("Live Latex Compilation Disabled")
    end, {})

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        pattern = { "*.tex", "*.latex" },
        callback = function(ev)
            if not M.state.live_compile then
                return
            end

            M.compile_current_buffer()
        end
    })
end

return M
