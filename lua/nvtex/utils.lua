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
        vim.print('An error has occured')
    end
end

function table_contains(table, value)
    for _, v in pairs(table) do
        if value == v then
            return true
        end
    end
    return false
end

return {
    split_once = split_once,
    check_error = check_error,
    table_contains = table_contains
}
