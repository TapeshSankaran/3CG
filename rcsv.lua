
function read_csv(filename)
    local file = io.open(filename, "r")
    local data = {}
    for line in file:lines() do
        local row = {}
        for value in string.gmatch(line, '([^,]+)') do
            table.insert(row, value)
        end
        table.insert(data, row)
    end
    file:close()
    return data
end