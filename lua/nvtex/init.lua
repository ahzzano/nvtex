local M = {}

-- other stuff
local utils = require 'nvtex.utils'

-- Plenary
local job = require 'plenary.job'

local default_settings = {
    pdfviewer = "sumatra",
    compiler = "pdflatex"
}

M.state = {
    live_compile = false,
    files_to_compile = {}
}

function M.compile_current_buffer()
    local currentbuffer = vim.api.nvim_buf_get_name(0)

    job:new({
        command = 'pdflatex',
        args = { currentbuffer },
        cwd = './',
        on_stdout = function(j, return_val)
            utils.check_error(return_val)
        end,
    }):start()
end

function M.compile_file(file)
    local currentbuffer = vim.api.nvim_buf_get_name(0)

    job:new({
        command = 'pdflatex',
        args = { file },
        cwd = './',
        on_stdout = function(j, return_val)
            utils.check_error(return_val)
        end,
    }):start()
end

function M.setup()
    vim.api.nvim_create_user_command("LatexAddToCompile", function()
        local currentbuffer = vim.api.nvim_buf_get_name(0)
        if vim.bo.filetype == 'latex' or vim.bo.filetype == 'tex' then
            table.insert(M.state.files_to_compile, currentbuffer)
            print("Added file to compilation targets")
        end
    end, {})

    vim.api.nvim_create_user_command("LatexLiveCompile", function()
        M.state.live_compile = not M.state.live_compile
        if M.state.live_compile then
            vim.print("Live Latex Compilation Enabled")
        else
            vim.print("Live Latex Compilation Disabled")
        end
    end, {})

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        pattern = { "*.tex", "*.latex" },
        callback = function()
            if not M.state.live_compile then
                return
            end
            if next(M.state.files_to_compile) ~= nil then
                for k, v in pairs(M.state.files_to_compile) do
                    vim.print("Compiling " .. v .. "...")
                    M.compile_file(v)
                end
            else
                vim.print("Compiling current buffer")
                M.compile_current_buffer()
            end
        end
    })
end

return M
