-- ~/.config/nvim/lua/config/functions.lua
-- Utility functions

local M = {}

-- Ensure directory exists for a filepath
function M.ensure_directory(filepath)
  local dir = vim.fn.fnamemodify(filepath, ':h')
  if dir ~= '' and dir ~= '.' and vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
  end
end

-- Pipe :messages to a new buffer
function M.pipe_messages_to_buffer()
  local messages_output = vim.api.nvim_exec('messages', true)
  vim.cmd 'enew'
  vim.bo.buftype = 'nofile'
  vim.bo.swapfile = false
  vim.bo.bufhidden = 'wipe'
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(messages_output, '\n'))
end

-- Toggle the quickfix window
function M.toggle_quickfix()
  local is_open = false
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      is_open = true
      break
    end
  end
  if is_open then
    vim.cmd 'cclose'
  else
    local height = math.floor(vim.o.lines * 0.5)
    vim.cmd('copen ' .. height)
  end
end

-- Copy full file path:line to clipboard
function M.copy_full_path_to_clipboard()
  local full_path = vim.fn.expand '%:p'
  if full_path == '' then
    print 'No file path associated with buffer.'
    return
  end
  local line_num = vim.fn.line '.'
  local full_path_with_line = full_path .. ':' .. line_num
  vim.fn.setreg('+', full_path_with_line)
  vim.notify('Copied to clipboard: ' .. full_path_with_line, vim.log.levels.INFO)
end

-- Go to file under cursor or create it
function M.goto_or_create()
  local filename = vim.fn.expand '<cfile>'
  if filename == '' then
    print 'No filename under cursor.'
    return
  end
  M.ensure_directory(filename)
  if vim.fn.filereadable(filename) == 1 or vim.fn.isdirectory(filename) == 1 then
    vim.cmd('edit ' .. vim.fn.fnameescape(filename))
  else
    vim.cmd('edit ' .. vim.fn.fnameescape(filename))
    print('Created and opened new file: ' .. filename)
  end
end

-- Set makeprg from visual selection
function M.set_makeprg_from_visual_selection()
  local old_reg = vim.fn.getreg '"'
  local old_reg_type = vim.fn.getregtype '"'
  vim.cmd 'normal! `<v`>y'
  local selected_text = vim.fn.getreg '"'
  vim.fn.setreg('"', old_reg, old_reg_type)

  if selected_text == '' then
    print 'No text selected.'
    return
  end

  vim.opt_local.makeprg = selected_text
  vim.notify('Set local makeprg to: ' .. selected_text, vim.log.levels.INFO)
end

-- Set makeprg from current line comment
function M.process_and_set_makeprg()
  local line = vim.api.nvim_get_current_line()
  local processed_line = line:match('^%s*[%-%/*#$]+%s*(.*)')

  if not processed_line then
    processed_line = line:match('^%s*(.*)')
  end
  processed_line = processed_line:gsub('^%s*', ''):gsub('%s*$', '')

  if processed_line == '' then
    print 'Could not extract command from line.'
    return
  end

  vim.opt_local.makeprg = processed_line
  vim.notify('Set local makeprg to: ' .. processed_line, vim.log.levels.INFO)

  local ns = vim.api.nvim_create_namespace 'makeprg_highlight'
  vim.api.nvim_buf_add_highlight(0, ns, 'Visual', vim.fn.line('.') - 1, 0, -1)
  vim.defer_fn(function() vim.api.nvim_buf_clear_namespace(0, ns, 0, -1) end, 750)
end

-- Toggle diagnostics
local diagnostics_active = true
function M.toggle_diagnostics()
  diagnostics_active = not diagnostics_active
  if diagnostics_active then
    vim.diagnostic.enable()
    vim.notify 'Diagnostics Enabled'
  else
    vim.diagnostic.disable()
    vim.notify 'Diagnostics Disabled'
  end
end

-- Save quickfix list to file
local function sanitize_command(cmd)
  local sanitized = cmd:gsub('^:%s*', ''):gsub('^Dispatch%s+', ''):gsub('%s*%([^)]*%)', ''):gsub('%s+', '_'):gsub('[/\\]', '_')
  return sanitized == '' and 'quickfix' or sanitized
end

function M.save_quickfix_to_file()
  local qf_info = vim.fn.getqflist { title = 1, items = 1 }
  if not qf_info or not qf_info.items or #qf_info.items == 0 then
    print 'Quickfix list is empty.'
    return
  end

  local title = qf_info.title or 'quickfix_list'
  local command = sanitize_command(title)
  local timestamp = os.time()
  local filename = string.format('%s_%s.txt', timestamp, command)
  local current_dir = vim.fn.expand './'
  local output_file = current_dir .. filename

  local lines = {}
  for _, item in ipairs(qf_info.items) do
    table.insert(lines, item.text or '')
  end

  local success = pcall(vim.fn.writefile, lines, output_file)
  if success then
    vim.notify('Quickfix list saved to ' .. output_file, vim.log.levels.INFO)
  else
    vim.notify('Error saving quickfix list to ' .. output_file, vim.log.levels.ERROR)
  end
end

-- Create C template project
function M.create_c_template()
  local dir = vim.fn.input 'Enter directory name for C project: '
  if dir == '' then
    print 'No directory entered.'
    return
  end
  local home = vim.fn.expand '~'
  local target_dir = home .. '/test/c/' .. dir
  vim.fn.mkdir(target_dir, 'p')

  local c_filepath = target_dir .. '/main.c'
  local c_template = [[
/* Compile and run: clang -Wall -Wextra -pedantic -std=c11 -o main main.c && ./main */
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    printf("Hello, World!\n");
    return EXIT_SUCCESS;
}
]]
  local c_file = io.open(c_filepath, 'w')
  if c_file then
    c_file:write(c_template)
    c_file:close()
  else
    print('Error creating file: ' .. c_filepath)
    return
  end

  local make_filepath = target_dir .. '/Makefile'
  local make_template = [[
CC = clang
CFLAGS = -Wall -Wextra -pedantic -std=c11 -g
TARGET = main
SRC = main.c

.PHONY: all run clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC)

run: all
	./$(TARGET)

clean:
	rm -f $(TARGET)
]]
  local make_file = io.open(make_filepath, 'w')
  if make_file then
    make_file:write(make_template)
    make_file:close()
  else
    print('Error creating file: ' .. make_filepath)
  end

  vim.cmd('edit ' .. vim.fn.fnameescape(c_filepath))
  vim.notify('C project template created in ' .. target_dir, vim.log.levels.INFO)
end

-- Close all undisplayed buffers
function M.close_undisplayed_buffers()
  local displayed_buffers = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    displayed_buffers[vim.api.nvim_win_get_buf(win)] = true
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if not displayed_buffers[buf] then
      local buftype = vim.bo[buf].buftype
      local modifiable = vim.bo[buf].modifiable
      local modified = vim.bo[buf].modified
      local name = vim.api.nvim_buf_get_name(buf)

      if modifiable and modified and buftype == "" and name ~= "" then
        vim.api.nvim_buf_call(buf, function()
          vim.cmd("silent! write")
        end)
      end
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
end

-- Surround visual selection with org block
function M.surround_visual_with_org_block()
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"
  local start_line_num = start_pos[2]
  local end_line_num = end_pos[2]

  local block_type = vim.fn.input 'Enter org block type (e.g., src, quote): '
  if block_type == '' then
    print 'Invalid block type entered.'
    return
  end

  local lang = ''
  if block_type == 'src' then
    lang = vim.fn.input 'Enter source language (e.g., lua, python): '
    if lang ~= '' then
      block_type = block_type .. ' ' .. lang
    end
  end

  local start_block = '#+begin_' .. block_type
  local block_type_tokens = block_type:match("%S+")
  local end_block = '#+end_' .. block_type_tokens

  local indent_str = vim.fn.matchstr(vim.api.nvim_buf_get_lines(0, start_line_num - 1, start_line_num, false)[1], '^%s*')

  vim.api.nvim_buf_set_lines(0, end_line_num, end_line_num, false, { indent_str .. end_block })
  vim.api.nvim_buf_set_lines(0, start_line_num - 1, start_line_num - 1, false, { indent_str .. start_block })

  vim.fn.setpos("'<", { start_pos[1], start_line_num + 1, start_pos[3], start_pos[4] })
  vim.fn.setpos("'>", { end_pos[1], end_line_num + 1, end_pos[3], end_pos[4] })
end

function M.surround_visual_with_bash_org_block()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line_num = start_pos[2]
  local end_line_num = end_pos[2]

  local line = vim.api.nvim_buf_get_lines(0, start_line_num - 1, start_line_num, false)[1]
  local indent_str = line:match("^%s*") or ""

  local start_block_lines = { indent_str .. "#+begin_src bash" }
  local end_block_line = indent_str .. "#+end_src"

  vim.api.nvim_buf_set_lines(0, end_line_num, end_line_num, false, { end_block_line })
  vim.api.nvim_buf_set_lines(0, start_line_num - 1, start_line_num - 1, false, start_block_lines)

  vim.fn.setpos("'<", { 0, start_line_num + 2, 1, 0 })
  vim.fn.setpos("'>", { 0, end_line_num + 2, 1, 0 })
end

function M.surround_visual_with_example_org_block()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line_num = start_pos[2]
  local end_line_num = end_pos[2]

  local line = vim.api.nvim_buf_get_lines(0, start_line_num - 1, start_line_num, false)[1]
  local indent_str = line:match("^%s*") or ""

  local start_block_lines = {
    indent_str .. "#+RESULTS:",
    indent_str .. "#+begin_example"
  }
  local end_block_line = indent_str .. "#+end_example"

  vim.api.nvim_buf_set_lines(0, end_line_num, end_line_num, false, { end_block_line })
  vim.api.nvim_buf_set_lines(0, start_line_num - 1, start_line_num - 1, false, start_block_lines)

  vim.fn.setpos("'<", { 0, start_line_num + 2, 1, 0 })
  vim.fn.setpos("'>", { 0, end_line_num + 2, 1, 0 })
end

-- Fold everything except visual selection
function M.fold_except_selection()
  local api = vim.api
  local bufnr = api.nvim_get_current_buf()
  local winnr = api.nvim_get_current_win()

  local start_pos = api.nvim_buf_get_mark(bufnr, "<")
  local end_pos = api.nvim_buf_get_mark(bufnr, ">")

  local start_line = math.min(start_pos[1], end_pos[1])
  local end_line = math.max(start_pos[1], end_pos[1])

  local total = api.nvim_buf_line_count(bufnr)

  if start_line > total or end_line < 1 then
    return
  end

  vim.wo[winnr].foldmethod = "manual"
  vim.wo[winnr].foldenable = true
  vim.wo[winnr].foldminlines = 1

  vim.cmd("silent! normal! zE")

  if start_line > 1 then
    vim.cmd(("%d,%dfold"):format(1, start_line - 1))
  end

  if end_line < total then
    vim.cmd(("%d,%dfold"):format(end_line + 1, total))
  end

  api.nvim_win_set_cursor(winnr, { start_line, 0 })
  vim.cmd("normal! zz")
end

-- Org heading to tmp file and run command
function M.org_heading_to_tmp_and_run(opts)
  opts = opts or {}
  local dir = opts.dir or "/tmp/org-extract"
  local ext = opts.ext or ".org"
  local cmd = opts.cmd or { "cat" }
  dir = vim.fn.expand(dir)
  dir = vim.fn.fnamemodify(dir, ":p")

  vim.fn.mkdir(dir, "p")

  local old_reg = vim.fn.getreg('"')
  local old_type = vim.fn.getregtype('"')

  vim.api.nvim_feedkeys('v', 'n', false)
  local ok = pcall(function()
    require("orgmode.org.text_objects").around_heading()
  end)
  if not ok then
    vim.notify("orgmode text object not available.", vim.log.levels.ERROR)
    return
  end
  vim.cmd('normal! y')

  local content = vim.fn.getreg('"') or ""
  vim.fn.setreg('"', old_reg, old_type)
  if content == "" then
    vim.notify("Nothing yanked.", vim.log.levels.WARN)
    return
  end

  vim.cmd("belowright new")
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "org"
  vim.bo[buf].modifiable = true

  vim.wo[win].foldenable = false
  vim.wo[win].foldmethod = "manual"
  vim.wo[win].foldlevel = 999

  local lines = vim.split(content, "\n", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.cmd("normal! gg")
  pcall(vim.cmd, "normal! zR")

  local function make_path()
    local fname = string.format(vim.fn.rand(), ext)
    return dir .. "/" .. fname
  end

  local function confirm_and_run()
    local path = make_path()
    local curr = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
    vim.fn.writefile(curr, path)

    local args = {}
    for _, a in ipairs(cmd) do
      table.insert(args, vim.fn.expand(a))
    end
    table.insert(args, path)

    vim.fn.jobstart(args, {
      stdout_buffered = true,
      stderr_buffered = true,
      on_stdout = function(_, data)
        if data and #data > 0 then
          vim.notify(table.concat(data, "\n"), vim.log.levels.INFO, { title = "Command output" })
        end
      end,
      on_stderr = function(_, data)
        if data and table.concat(data, "") ~= "" then
          vim.notify(table.concat(data, "\n"), vim.log.levels.ERROR, { title = "Command error" })
        end
      end,
    })

    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_set_name(buf, path)
      vim.bo[buf].buftype = ""
      vim.bo[buf].swapfile = true
      vim.api.nvim_buf_set_option(buf, "modified", false)
    end

    vim.notify(("Wrote %s and ran: %s"):format(path, table.concat(args, " ")), vim.log.levels.INFO, { title = "Org extract" })
  end

  local function cancel()
    if vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
    vim.notify("Aborted", vim.log.levels.WARN, { title = "Org extract" })
  end

  local aug = vim.api.nvim_create_augroup("OrgExtractPreviewAU", { clear = false })
  vim.api.nvim_create_autocmd("BufLeave", {
    group = aug,
    buffer = buf,
    once = true,
    callback = function()
      pcall(vim.api.nvim_del_augroup_by_id, aug)
      vim.ui.select({ "Yes", "No" }, { prompt = "Confirm extract?" }, function(choice)
        if choice == "Yes" then
          if vim.api.nvim_buf_is_valid(buf) then
            confirm_and_run()
          else
            vim.notify("Preview closed before confirming; nothing done.", vim.log.levels.WARN)
          end
        else
          cancel()
        end
      end)
    end,
  })

  vim.notify("Preview opened (unfolded). When you leave this split, you'll get a Yes/No prompt.", vim.log.levels.INFO, { title = "Org extract" })
end

return M

