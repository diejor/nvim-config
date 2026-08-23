-- Hex view of debuggee memory, on top of the DAP readMemory request.
--
-- codelldb advertises supportsReadMemoryRequest but never returns a
-- memoryReference on evaluate, so the address comes from a (void*) cast of
-- whatever expression you hand it.

local M = {}

local state = nil -- { expr, ref, offset, count, group, buf, win }

local function frame()
    local session = require("dap").session()
    if not session then
        return nil, nil, "no debug session"
    end
    if not session.current_frame then
        return nil, nil, "not stopped in a frame"
    end
    return session, session.current_frame
end

local function show(lines)
    -- LLDB error strings are multi-line; nvim_buf_set_lines rejects embedded
    -- newlines, so flatten before handing them over.
    local flat = {}
    for _, line in ipairs(lines) do
        vim.list_extend(flat, vim.split(line, "\n", { plain = true }))
    end
    vim.bo[state.buf].modifiable = true
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, flat)
    vim.bo[state.buf].modifiable = false
end

local function fail(msg)
    vim.schedule(function()
        if state and state.buf and vim.api.nvim_buf_is_valid(state.buf) then
            show({ ("%s  --  %s"):format(state.expr, msg), "", "Press q to close." })
        end
    end)
end

local function render(address, raw)
    local lines = {
        ("%s  %s  %d bytes  (group %d)"):format(state.expr, address, #raw, state.group),
        "",
    }
    local base = tonumber(address)
    for off = 0, #raw - 1, 16 do
        local chunk = raw:sub(off + 1, math.min(off + 16, #raw))
        local groups, hex, ascii = {}, {}, {}
        for i = 1, #chunk do
            local byte = chunk:byte(i)
            hex[#hex + 1] = ("%02x"):format(byte)
            ascii[#ascii + 1] = (byte >= 32 and byte < 127) and string.char(byte) or "."
            if i % state.group == 0 or i == #chunk then
                groups[#groups + 1] = table.concat(hex, " ")
                hex = {}
            end
        end
        lines[#lines + 1] = ("%012x  %-53s |%s|")
            :format(base + off, table.concat(groups, "  "), table.concat(ascii))
    end

    show(lines)
end

--- Look up a bare leaf name in the frame's variable tree.
--- Lines in the Scopes pane carry only the leaf (`data`), which is not a valid
--- expression anywhere. The adapter, though, hands back a qualified
--- `evaluateName` for every variable (`v.data`), so recover it from there.
local function qualify(session, frame_id, name, cb)
    session:request("scopes", { frameId = frame_id }, function(err, scopes)
        if err or not scopes then
            return cb(nil)
        end
        local pending, found = 0, nil
        local function scan(ref, depth)
            pending = pending + 1
            session:request("variables", { variablesReference = ref }, function(var_err, res)
                if not var_err and res then
                    for _, v in ipairs(res.variables) do
                        if v.name == name and v.evaluateName then
                            found = found or v.evaluateName
                        elseif not found and depth < 3 and (v.variablesReference or 0) > 0 then
                            scan(v.variablesReference, depth + 1)
                        end
                    end
                end
                pending = pending - 1
                if pending == 0 then
                    cb(found)
                end
            end)
        end
        for _, scope in ipairs(scopes.scopes) do
            -- Skip Globals/Registers; walking those is slow and never what we want.
            if (scope.variablesReference or 0) > 0 and not scope.expensive then
                scan(scope.variablesReference, 1)
            end
        end
        if pending == 0 then
            cb(nil)
        end
    end)
end

local function fetch(retried)
    local session, current, err = frame()
    if not session then
        fail(err)
        return
    end

    session:request(
        "evaluate",
        { expression = ("(void*)(%s)"):format(state.expr), frameId = current.id, context = "watch" },
        function(eval_err, eval)
            if eval_err or not eval.result:match("^0x") then
                if retried or state.expr:match("[^%w_]") then
                    fail("no address for this expression: " .. tostring(eval_err or eval.result))
                    return
                end
                -- A bare name that did not resolve: try the qualified form.
                qualify(session, current.id, state.expr, function(qualified)
                    if qualified and qualified ~= state.expr then
                        state.expr = qualified
                        fetch(true)
                    else
                        fail("no address for this expression: " .. tostring(eval_err or eval.result))
                    end
                end)
                return
            end
            state.ref = eval.result
            session:request(
                "readMemory",
                { memoryReference = state.ref, offset = state.offset, count = state.count },
                function(read_err, read)
                    if read_err then
                        fail(tostring(read_err))
                        return
                    end
                    vim.schedule(function()
                        render(read.address, vim.base64.decode(read.data or ""))
                    end)
                end
            )
        end
    )
end

local function open_window()
    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
        return
    end
    state.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[state.buf].filetype = "dap-memory"
    vim.bo[state.buf].bufhidden = "wipe"

    state.win = vim.api.nvim_open_win(state.buf, true, {
        relative = "editor",
        width = math.min(90, vim.o.columns - 4),
        height = math.min(20, vim.o.lines - 6),
        row = 2,
        col = math.max(0, math.floor((vim.o.columns - 90) / 2)),
        border = "rounded",
        title = " memory ",
    })
    vim.wo[state.win].wrap = false

    local function map(lhs, fn, desc)
        vim.keymap.set("n", lhs, fn, { buffer = state.buf, desc = desc })
    end
    map("q", function() vim.api.nvim_win_close(state.win, true) end, "Close")
    map("r", fetch, "Refresh")
    map("]", function() state.offset = state.offset + state.count fetch() end, "Next page")
    map("[", function() state.offset = math.max(0, state.offset - state.count) fetch() end, "Prev page")
    map("+", function() state.count = state.count * 2 fetch() end, "Twice as many bytes")
    map("-", function() state.count = math.max(16, state.count / 2) fetch() end, "Half as many bytes")
    map("w", function() state.group = state.group == 1 and 4 or (state.group == 4 and 8 or 1) fetch() end, "Cycle grouping")
end

--- The C expression under the cursor, or the visual selection.
--- <cexpr> beats <cword>: on `v->data[v->len]` it yields `v->data`, where
--- <cword> would hand the debugger a bare `data` that is not in scope.
local function current_expr()
    if vim.fn.mode():match("^[vV\22]") then
        vim.cmd('normal! "vy')
        return vim.fn.getreg("v"):gsub("\n", " ")
    end
    return vim.fn.expand("<cexpr>")
end

--- Hex-dump the memory an expression points at.
---@param expr string? defaults to the expression under the cursor
---@param count integer? bytes to read, default 128
function M.open(expr, count)
    expr = expr and expr ~= "" and expr or current_expr()
    if expr == "" then
        return
    end
    state = { expr = expr, offset = 0, count = count or 128, group = 4 }
    open_window()
    fetch()
end

return M
