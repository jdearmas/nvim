--[[
--
-- This is a Lua program that is executed when Neovim starts.
--
-- This configures Neovim, downloads plugins, sets keybindings, and defines commands, among other things.
--
-- This is the only file that is required.
--
--]]

-- This section installs the lazy.nvim plugin manager.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end

-- This section adds the lazy.nvim plugin manager to the runtimepath.
vim.opt.rtp:prepend(lazypath)

-- Enable relative line numbers
vim.wo.relativenumber = true

-- Enable absolute line number for the current line
vim.wo.number = true

-- Example using a list of specs with the default options.
-- `mapleader` must be set before lazy.
vim.g.mapleader = " "
vim.api.nvim_set_keymap("n", "<leader>e", ":edit $MYVIMRC<CR>", { noremap = true, silent = true })

-- Function to capture and pipe messages to a new buffer
function pipe_messages_to_buffer()
	-- Capture the output of the :messages command
	local messages = vim.api.nvim_exec("messages", true)

	-- Open a new buffer
	vim.cmd("enew")

	-- Set the buffer to be a scratch buffer (not saved)
	vim.bo.buftype = "nofile"
	vim.bo.swapfile = false
	vim.bo.bufhidden = "wipe"

	-- Insert the messages into the buffer
	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(messages, "\n"))
end

-- Create a keybinding to call the function
vim.api.nvim_set_keymap("n", "<leader>O", ":lua pipe_messages_to_buffer()<CR>", { noremap = true, silent = true })

-- A modern plugin manager for Neovim.
require("lazy").setup({
	"tpope/vim-dispatch",
	"radenling/vim-dispatch-neovim",
	"maralla/completor.vim",
	"pocco81/true-zen.nvim",
	{
		"stevearc/aerial.nvim",
		opts = {},
		-- Optional dependencies
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
	},
	{
		"yacineMTB/dingllm.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local system_prompt =
				"You should replace the code that you are sent, only following the comments. Do not talk at all. Only output valid code. Do not provide any backticks that surround the code. Never ever output backticks like this ```. Any comment that is asking you for something should be removed after you satisfy them. Other comments should left alone. Do not output backticks"
			local helpful_prompt = "You are a helpful assistant. What I have sent are my notes so far."
			local dingllm = require("dingllm")

			local function handle_open_router_spec_data(data_stream)
				local success, json = pcall(vim.json.decode, data_stream)
				if success then
					if json.choices and json.choices[1] and json.choices[1].text then
						local content = json.choices[1].text
						if content then
							dingllm.write_string_at_cursor(content)
						end
					end
				else
					print("non json " .. data_stream)
				end
			end

			local function custom_make_openai_spec_curl_args(opts, prompt)
				local url = opts.url
				local api_key = opts.api_key_name and os.getenv(opts.api_key_name)
				local data = {
					prompt = prompt,
					model = opts.model,
					temperature = 0.7,
					stream = true,
				}
				local args = { "-N", "-X", "POST", "-H", "Content-Type: application/json", "-d", vim.json.encode(data) }
				if api_key then
					table.insert(args, "-H")
					table.insert(args, "Authorization: Bearer " .. api_key)
				end
				table.insert(args, url)
				return args
			end

			local function llama_405b_base()
				dingllm.invoke_llm_and_stream_into_editor({
					url = "https://openrouter.ai/api/v1/chat/completions",
					model = "meta-llama/llama-3.1-405b",
					api_key_name = "OPEN_ROUTER_API_KEY",
					max_tokens = "128",
					replace = false,
				}, custom_make_openai_spec_curl_args, handle_open_router_spec_data)
			end

			local function groq_replace()
				dingllm.invoke_llm_and_stream_into_editor({
					url = "https://api.groq.com/openai/v1/chat/completions",
					model = "llama-3.1-70b-versatile",
					api_key_name = "GROQ_API_KEY",
					system_prompt = system_prompt,
					replace = true,
				}, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
			end

			local function groq_help()
				dingllm.invoke_llm_and_stream_into_editor({
					url = "https://api.groq.com/openai/v1/chat/completions",
					model = "llama-3.1-70b-versatile",
					api_key_name = "GROQ_API_KEY",
					system_prompt = helpful_prompt,
					replace = false,
				}, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
			end

			local function llama405b_replace()
				dingllm.invoke_llm_and_stream_into_editor({
					url = "https://api.lambdalabs.com/v1/chat/completions",
					model = "hermes-3-llama-3.1-405b-fp8",
					api_key_name = "LAMBDA_API_KEY",
					system_prompt = system_prompt,
					replace = true,
				}, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
			end

			local function llama405b_help()
				dingllm.invoke_llm_and_stream_into_editor({
					url = "https://api.lambdalabs.com/v1/chat/completions",
					model = "hermes-3-llama-3.1-405b-fp8",
					api_key_name = "LAMBDA_API_KEY",
					system_prompt = helpful_prompt,
					replace = false,
				}, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
			end

			local function anthropic_help()
				dingllm.invoke_llm_and_stream_into_editor({
					url = "https://api.anthropic.com/v1/messages",
					model = "claude-3-5-sonnet-20240620",
					api_key_name = "ANTHROPIC_API_KEY",
					system_prompt = helpful_prompt,
					replace = false,
				}, dingllm.make_anthropic_spec_curl_args, dingllm.handle_anthropic_spec_data)
			end

			local function anthropic_replace()
				dingllm.invoke_llm_and_stream_into_editor({
					url = "https://api.anthropic.com/v1/messages",
					model = "claude-3-5-sonnet-20240620",
					api_key_name = "ANTHROPIC_API_KEY",
					system_prompt = system_prompt,
					replace = true,
				}, dingllm.make_anthropic_spec_curl_args, dingllm.handle_anthropic_spec_data)
			end

			vim.keymap.set({ "v" }, "<leader>k", groq_replace, { desc = "llm groq" })
			vim.keymap.set({ "v" }, "<leader>K", groq_help, { desc = "llm groq_help" })
			vim.keymap.set({ "v" }, "<leader>L", llama405b_help, { desc = "llm llama405b_help" })
			vim.keymap.set({ "v" }, "<leader>l", llama405b_replace, { desc = "llm llama405b_replace" })
			vim.keymap.set({ "v" }, "<leader>I", anthropic_help, { desc = "llm anthropic_help" })
			vim.keymap.set({ "v" }, "<leader>i", anthropic_replace, { desc = "llm anthropic" })
			vim.keymap.set({ "v" }, "<leader>o", llama_405b_base, { desc = "llama base" })
		end,
	},
	{
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- install jsregexp (optional!).
		-- build = "make install_jsregexp",
	},
	{
		"stevearc/overseer.nvim",
		opts = {},
	},
	{
		"folke/twilight.nvim",
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},
	{
		"pianocomposer321/officer.nvim",
		dependencies = "stevearc/overseer.nvim",
		config = function()
			require("officer").setup({
				-- config
			})
		end,
	},
	{ "shortcuts/no-neck-pain.nvim", version = "*" },
	"lukas-reineke/indent-blankline.nvim",
	"jdearmas/taboo",
	"mattn/emmet-vim",
	"mbbill/undotree",
	"nvim-treesitter/nvim-treesitter-context",
	{
		"MattesGroeger/vim-bookmarks",
		config = function()
			vim.g.bookmark_sign = "⚑"
			vim.g.bookmark_highlight_lines = 1
		end,
	},
	"github/copilot.vim",
	"mtikekar/nvim-send-to-term",
	"sbdchd/neoformat",
	"williamboman/mason.nvim",
	"yorickpeterse/nvim-window",
	{ "ptzz/lf.vim", dependencies = { "voldikss/vim-floaterm" } },
	{
		{
			"NeogitOrg/neogit",
			dependencies = {
				"nvim-lua/plenary.nvim", -- required
				"nvim-telescope/telescope.nvim", -- optional
				"sindrets/diffview.nvim", -- optional
				"ibhagwan/fzf-lua", -- optional
			},
			config = true,
		},
		"folke/which-key.nvim",
		config = function()
			require("which-key").setup({})
		end,
	},
	{
		"chomosuke/term-edit.nvim",
		lazy = false, -- or ft = 'toggleterm' if you use toggleterm.nvim
		version = "1.*",
	},
	{
		"VonHeikemen/fine-cmdline.nvim",
		dependencies = {
			{ "MunifTanjim/nui.nvim" },
		},
	},
	{
		"ray-x/go.nvim",
		dependencies = { -- optional packages
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("go").setup()
		end,
		event = { "CmdlineEnter" },
		ft = { "go", "gomod" },
		build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
	},
	-- "tpope/vim-dispatch",
	"chrisbra/Colorizer",
	"junegunn/fzf",
	"junegunn/fzf.vim",
	"williamboman/mason-lspconfig.nvim",
	"tpope/vim-commentary",
	{ "nvim-telescope/telescope.nvim" },
	{ "nvim-lua/plenary.nvim" },
	{ "nvim-telescope/telescope-fzf-native.nvim" },
	"nvim-telescope/telescope-media-files.nvim",
	{ "VonHeikemen/lsp-zero.nvim", branch = "v4.x" },
	{ "neovim/nvim-lspconfig" },
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "hrsh7th/nvim-cmp" },
	{
		"nvim-treesitter/nvim-treesitter",
		ensure_installed = {
			"c",
			"diff",
			"git_config",
			"git_rebase",
			"gitattributes",
			"gitcommit",
			"gitignore",
			"go",
			"html",
			"http",
			"javascript",
			"json",
			"lua",
			"markdown",
			"markdown_inline",
			"norg",
			"python",
			"query",
			"rust",
			"sql",
			"toml",
			"vim",
			"vimdoc",
			"xml",
			"yaml",
		},
	},

	{
		"nvim-orgmode/orgmode",
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter", lazy = true },
		},
		event = "VeryLazy",
		config = function()
			-- Setup orgmode
			require("orgmode").setup({
				org_agenda_files = { "~/org/**/*" },
				org_default_notes_file = "~/org/todo.org",
				org_todo_keywords = { "TODO", "|", "DONE", "FAILED" },
			})
		end,
	},
})

-- Set enhanced_diff_hl to true for the 'diffview' module
require("diffview").setup({
	enhanced_diff_hl = true,
})

-- Lanaguage Server Protocol (LSP) configuration.
--
local lsp_zero = require("lsp-zero")
lsp_zero.extend_lspconfig({
	sign_text = true,
	lsp_attach = lsp_attach,
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})
-- Set up clangd with default settings
lsp_zero.configure("clangd", {})
-- Meson LSP configuration
lsp_zero.configure("mesonlsp", {})
lsp_zero.setup()
lsp_zero.on_attach(function(client, bufnr)
	-- see :help lsp-zero-keybindings
	-- to learn the available actions
	local opts = { buffer = bufnr, remap = false }
	lsp_zero.default_keymaps({ buffer = bufnr })
end)

-- lsp_attach is where you enable features that only work
-- if there is a language server active in the file
local lsp_attach = function(client, bufnr)
	local opts = { buffer = bufnr }

	vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
	vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
	vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
	vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
	vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
	vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
	vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
	vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
	vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
	vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
end

require("ibl").setup()

require("mason").setup({
	PATH = "prepend",
})
require("mason-lspconfig").setup({
	ensure_installed = {
		"clangd",
		"gopls",
		"lua_ls",
		"pylsp",
		"terraformls",
	},
	handlers = {
		lsp_zero.default_setup,
	},
})

lsp_zero.setup_servers({ "lua_ls", "rust_analyzer" })

local cmp = require("cmp")
local cmp_action = require("lsp-zero").cmp_action()

cmp.setup({
	sources = cmp.config.sources({
		{ name = "nvim_lsp" }, -- LSP source
		{ name = "luasnip" }, -- Snippet source
	}, {
		{ name = "buffer" }, -- Buffer source
		{ name = "path" }, -- Path source
	}),
	completion = {
		autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged }, -- Trigger on typing
	},
	mapping = cmp.mapping.preset.insert({
		-- `Enter` key to confirm completion
		["<CR>"] = cmp.mapping.confirm({ select = false }),

		-- Ctrl+Space to trigger completion menu
		-- ["<C-Space>"] = cmp.mapping.complete(),
		["<C-s"] = cmp.mapping.complete(),

		-- Navigate between snippet placeholder
		["<C-f>"] = cmp_action.luasnip_jump_forward(),
		["<C-b>"] = cmp_action.luasnip_jump_backward(),

		-- Scroll up and down in the completion documentation
		["<C-u>"] = cmp.mapping.scroll_docs(-4),
		["<C-d>"] = cmp.mapping.scroll_docs(4),
	}),
})

lsp_zero.setup_servers({
	"ts_ls",
	"rust_analyzer",
	"clangd",
	"mesonlsp",
	"dockerls",
	"eslint",
	"gopls",
	"html",
	"jsonls",
	"lua_ls",
	"pylsp",
	"yamlls",
})

-- Set relative line numbers
vim.opt.number = true -- Enable line numbers
vim.opt.relativenumber = true -- Enable relative line numbers

-- Folding configuration

-- Set folding method to 'indent'
vim.opt.foldmethod = "indent"

-- Set initial fold level to 1
vim.opt.foldlevelstart = 1

-- Enable folding
vim.opt.foldenable = true

-- Other configurations ...
-- Automatically format on save using Neoformat
vim.cmd([[
autocmd BufWritePre * silent! Neoformat
]])

-- Configure 'makeprg' for Python
vim.cmd([[
autocmd FileType python setlocal makeprg=python3\ %
autocmd FileType python setlocal errorformat=%f:%l:\ %m
]])

-- Create a function that will toggle thhe quickfix window.
-- If the quickfix window is open, close it. If it is closed, open it.
function ToggleQuickFix()
	local is_open = false
	-- Check if any quickfix window is open
	for _, win in ipairs(vim.fn.getwininfo()) do
		if win["quickfix"] == 1 then
			is_open = true
			break
		end
	end

	if is_open then
		-- Close the quickfix window if it is open
		vim.cmd("cclose")
	else
		-- Open the quickfix window if it is closed
		vim.cmd("copen")
	end
end

-- Rest of your init.lua configurations...
require("telescope").setup({
	extensions = {
		fzf = {
			fuzzy = true, -- Enable fuzzy search
			override_generic_sorter = true, -- Override the generic sorter
			override_file_sorter = true, -- Override the file sorter
		},
	},
})

-- Load fzf-native extension
-- require'telescope'.load_extension('fzf')

require("which-key").setup({
	show_help = true, -- Make sure the help message is shown (default)
	triggers = "auto", -- Automatically show the popup for a prefix key (default is "auto")
	-- ... other configurations ...
})

vim.api.nvim_set_keymap("n", "<leader>u", ":Lf<CR>", { noremap = true, silent = true })

function _G.set_terminal_keymaps()
	local opts = { buffer = 0 }
	vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
	vim.keymap.set("t", "hs", [[<C-\><C-n>]], opts)
	vim.keymap.set("n", "f", ":f ", opts)

	-- vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
	-- vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)

	-- vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
	vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
	vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
	vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
	vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

require("fine-cmdline").setup({
	cmdline = {
		enable_keymaps = true,
		smart_history = true,
		prompt = ": ",
	},
	popup = {
		position = {
			row = "50%",
			col = "50%",
		},
		size = {
			width = "60%",
		},
		border = {
			style = "rounded",
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
		},
	},
	hooks = {
		before_mount = function(input)
			-- code
		end,
		after_mount = function(input)
			-- code
		end,
		set_keymaps = function(imap, feedkeys)
			-- code
		end,
	},
})

set_keymaps = function(imap, feedkeys)
	local fn = require("fine-cmdline").fn

	imap("<M-k>", fn.up_search_history)
	imap("<M-j>", fn.down_search_history)
	imap("<Up>", fn.up_history)
	imap("<Down>", fn.down_history)
end

vim.api.nvim_set_keymap("n", ":", "<cmd>FineCmdline<CR>", { noremap = true })

vim.g.floaterm_width = 0.95
vim.g.floaterm_height = 0.95

-- Function to ask for a directory and then run :Files
local function fzf_files_with_input()
	local input = vim.fn.input("Enter directory: ", vim.fn.getcwd() .. "/", "dir")
	vim.cmd("Files " .. input)
end

vim.cmd([[hi! link SignColumn Normal]])
vim.cmd([[hi! Folded ctermbg=0]])
vim.o.clipboard = "unnamedplus"
vim.api.nvim_set_keymap("n", "<leader>a", ':lua require("nvim-window").pick()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>w", ":set wrap!<CR>", { noremap = true, silent = true })

-- vim.opt.readonly = true
-- vim.cmd('autocmd BufReadPre * set readonly')

vim.api.nvim_create_user_command("DiagnosticToggle", function()
	local config = vim.diagnostic.config
	local vt = config().virtual_text
	config({
		virtual_text = not vt,
		underline = not vt,
		signs = not vt,
	})
end, { desc = "toggle diagnostic" })

require("term-edit").setup({
	-- Mandatory option:
	-- Set this to a lua pattern that would match the end of your prompt.
	-- Or a table of multiple lua patterns where at least one would match the
	-- end of your prompt at any given time.
	-- For most bash/zsh user this is '%$ '.
	-- For most powershell/fish user this is '> '.
	-- For most windows cmd user this is '>'.
	prompt_end = { windows = "%$ ", bash = "> " },
	-- How to write lua patterns: https://www.lua.org/pil/20.2.html
})

goto_or_create = function()
	local filename = vim.fn.expand("<cfile>")
	if vim.fn.filereadable(filename) == 1 then
		vim.cmd("edit " .. filename)
	else
		vim.cmd("split " .. filename)
		vim.cmd("write")
	end
end

vim.api.nvim_set_keymap("n", "gf", ":lua goto_or_create()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>m", ":NoNeckPain<CR>", { noremap = true, silent = true })
-- Place this code in your Neovim configuration file (e.g., init.lua)

-- Assign the keybinding
vim.api.nvim_set_keymap("n", "<leader>i", ":new | terminal<CR>", { noremap = true, silent = true })

vim.opt.ignorecase = true

-- Define a custom highlight group for the border
vim.cmd("hi CustomVertSplit guibg=green")

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.softtabstop = 2
vim.opt.autoindent = true

-- Enable true color
vim.o.termguicolors = true

vim.api.nvim_set_hl(0, "Folded", { bg = "none" })

vim.api.nvim_set_keymap("n", "<leader>zn", ":TZNarrow<CR>", {})
vim.api.nvim_set_keymap("v", "<leader>zn", ":'<,'>TZNarrow<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>zf", ":TZFocus<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>zm", ":TZMinimalist<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>za", ":TZAtaraxis<CR>", {})

function copy_full_path_to_clipboard()
	local full_path = vim.fn.expand("%:p") -- Gets the full path of the current file
	local line_num = vim.fn.line(".") -- Gets the current line number
	local full_path_with_line = full_path .. ":" .. line_num
	vim.fn.setreg("+", full_path_with_line) -- Copies the full path with line number to the clipboard
	print("Path copied to clipboard: " .. full_path_with_line) -- Optional: prints a confirmation message
end

-- :%s/\(\S\+\)\s\+\(\S\+\)/\1 \2\\r/g
vim.opt.autochdir = true
vim.opt.scrollback = 100000
-- vim.opt.scrollback = -1
--
-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers["signature_help"], {
	border = "single",
	close_events = { "CursorMoved", "BufHidden" },
})
vim.keymap.set("i", "<c-s>", vim.lsp.buf.signature_help)
vim.keymap.set("n", "<space>nl", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "H", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<space>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
		-- vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
		-- vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "<space>f", function()
			vim.lsp.buf.format({ async = true })
		end, opts)
	end,
})

require("nvim-treesitter.configs").setup({
	-- Modules and its options go here
	highlight = { enable = true },
	incremental_selection = { enable = true },
	textobjects = { enable = true },
})

require("no-neck-pain").setup({
	buffers = {
		wo = {
			fillchars = "eob: ",
		},
	},
})

require("no-neck-pain").setup({
	buffers = {
		scratchPad = {
			-- set to `false` to
			-- disable auto-saving
			enabled = true,
			-- set to `nil` to default
			-- to current working directory
			location = "~/Documents/",
		},
		bo = {
			filetype = "md",
		},
	},
})

vim.api.nvim_set_keymap("", "<leader>j", "<C-w>j", { noremap = true, silent = true })
vim.api.nvim_set_keymap("", "<leader>k", "<C-w>k", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "hs", "<esc>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "hu", "<esc>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "7", "<C-w>=", {})
vim.api.nvim_set_keymap("n", "<leader>=", ":%!jq .<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>D", ":bd!<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>c", ":close<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>cp", ":lua copy_full_path_to_clipboard()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>s", ":split<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>tn", ":tabnew<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>tr", ":TabooRename<Space>", { noremap = true })
vim.api.nvim_set_keymap("n", "J", "<PageDown>", {})
vim.api.nvim_set_keymap("n", "K", "<PageUp>", {})
vim.api.nvim_set_keymap("n", "<leader>lr", ":luafile %<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>n", ":lua JumpToHover()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>r", ":only<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader><leader>", ":w!<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "x", ":Dispatch<CR>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "<leader>h", ":Dispatch<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", ";", ":lua ToggleQuickFix()<CR>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "<leader>q", ":lua ToggleQuickFix()<CR>", { noremap = true, silent = true })
local diagnostics_active = false
vim.keymap.set("n", "<leader>tt", function()
	diagnostics_active = not diagnostics_active
	if diagnostics_active then
		vim.diagnostic.enable()
	else
		vim.diagnostic.disable()
	end
end)
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.api.nvim_set_keymap("n", "<leader>fl", ":Telescope lsp_document_symbols<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>fo", ":Telescope oldfiles<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>fg", ":Telescope git_files<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>ff", ":Telescope find_files<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>fz", ":FZF<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>fc", ":Rg<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>b", ":Telescope buffers<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>gf", ":Telescope live_grep<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap(
	"n",
	"<leader>gb",
	":Telescope current_buffer_fuzzy_find<CR>",
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "<leader>gj", ":Telescope jumplist<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>go", ":Telescope vim_bookmarks all<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>t", ":SendHere<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>gs", ":Neogit<CR>", { noremap = true, silent = true })

function DeleteBuffersMatchingPattern()
	local pattern = vim.fn.input("Enter regex pattern: ")
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		local bufname = vim.api.nvim_buf_get_name(bufnr)
		if string.match(bufname, pattern) then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
	end
end

vim.api.nvim_set_keymap(
	"n",
	"<leader>db",
	[[:lua DeleteBuffersMatchingPattern()<CR>]],
	{ noremap = true, silent = true }
)

vim.api.nvim_create_autocmd("VimResized", {
	pattern = "*",
	command = "wincmd =",
})

vim.opt.termguicolors = true

vim.cmd([[set background=dark]])

vim.api.nvim_set_hl(0, "Normal", { bg = "#000000", fg = "#00FF00" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000", fg = "#00FF00" })

vim.api.nvim_set_keymap(
	"v",
	"<leader>m",
	[[:lua SetMakePrgFromVisualSelection()<CR>]],
	{ noremap = true, silent = true }
)

function SetMakePrgFromVisualSelection()
	-- Use vim.cmd to enter normal mode to get visual selection
	vim.cmd("normal! `<v`>y") -- Yank visually selected text into register
	local selected_text = vim.fn.getreg('"') -- Get the yanked text from unnamed register

	-- Escape spaces in the selected text
	local escaped_text = selected_text:gsub(" ", "\\ ")

	-- Use vim.cmd to set the makeprg
	vim.cmd("setlocal makeprg=" .. escaped_text)

	-- Print confirmation
	print("makeprg set to: " .. escaped_text)
end

vim.api.nvim_set_keymap("n", "<BS>", ":bp<CR>", { noremap = true, silent = true })

-- ========================================================================
-- ========================== Custom Highlighting =========================
-- ========================================================================
vim.api.nvim_set_hl(0, "DiffDelete", { fg = "#FF0000", bg = "NONE" })
vim.api.nvim_set_hl(0, "DiffAdd", { fg = "#00ff00", bg = "NONE" })
vim.api.nvim_set_hl(0, "DiffContext", { fg = "gray", bg = "NONE" })

vim.api.nvim_set_hl(0, "NeogitDiffDelete", { fg = "#FF0000", bg = "NONE" })
vim.api.nvim_set_hl(0, "NeogitDiffAdd", { fg = "#00ff00", bg = "NONE" })
vim.api.nvim_set_hl(0, "NeogitDiffContext", { fg = "gray", bg = "NONE" })

vim.api.nvim_set_hl(0, "NeogitDiffDeleteHighlight", { fg = "#ff0000", bg = "NONE" })
vim.api.nvim_set_hl(0, "NeogitDiffAddHighlight", { fg = "#00ff00", bg = "NONE" })
vim.api.nvim_set_hl(0, "NeogitDiffContextHighlight", { fg = "gray", bg = "NONE" })

vim.keymap.set("n", "<leader>Q", function()
	-- Gather buffers displayed in any window
	local displayed_buffers = {}
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		displayed_buffers[vim.api.nvim_win_get_buf(win)] = true
	end

	-- Iterate over all buffers
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if not displayed_buffers[buf] then
			local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
			local modifiable = vim.api.nvim_buf_get_option(buf, "modifiable")
			local modified = vim.api.nvim_buf_get_option(buf, "modified")
			local name = vim.api.nvim_buf_get_name(buf)

			-- If it's a modifiable text buffer with a filename and unsaved changes, save it
			if modifiable and modified and buftype == "" and name ~= "" then
				vim.api.nvim_buf_call(buf, function()
					vim.cmd("silent! write")
				end)
			end

			-- Delete the buffer (including terminal or unnamed buffers)
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end
end, { desc = "Save & close all undisplayed buffers" })

-- Keybinding for visual mode
vim.api.nvim_set_keymap(
	"v",
	"<leader>o",
	[[:<C-u>lua surround_visual_with_org_block()<CR>]],
	{ noremap = true, silent = true }
)

-- Define the function inline
function surround_visual_with_org_block()
	-- Get the visual selection range
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	-- Prompt the user for block type
	local block_type = vim.fn.input("Enter block type (e.g., src, quote): ")

	-- Validate the block type
	if block_type == "" then
		print("Invalid block type!")
		return
	end

	-- Construct the org block strings
	local start_block = "#+begin_" .. block_type
	local end_block

	-- Automatically handle `src` blocks
	if block_type:match("^src") then
		end_block = "#+end_src"
	else
		end_block = "#+end_" .. block_type
	end

	-- Determine the indentation level of the starting line
	local start_line = start_pos[2]
	local indent_level = vim.fn.indent(start_line)

	-- Prepare indented block strings
	local indent = string.rep(" ", indent_level)
	start_block = indent .. start_block
	end_block = indent .. end_block

	-- Insert the org blocks
	-- Go to the start position and insert the starting block
	vim.fn.setpos(".", start_pos)
	vim.cmd("normal! O" .. start_block)
	-- Adjust the end position since adding the block changes line numbers
	end_pos[2] = end_pos[2] + 1
	-- Go to the adjusted end position and insert the ending block
	vim.fn.setpos(".", end_pos)
	vim.cmd("normal! o" .. end_block)
end

-- Automatically create directories and files if they don't exist
local function ensure_directory(filepath)
	local dir = vim.fn.fnamemodify(filepath, ":h")
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end
end

local function create_file_if_not_exists(filepath)
	if vim.fn.filereadable(filepath) == 0 then
		local file = io.open(filepath, "w")
		if file then
			file:close()
		end
	end
end

vim.api.nvim_create_autocmd("BufNewFile", {
	pattern = "*",
	callback = function(ev)
		local filepath = ev.match
		ensure_directory(filepath)
		create_file_if_not_exists(filepath)
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(ev)
		local filepath = ev.match
		ensure_directory(filepath)
	end,
})

vim.api.nvim_set_keymap("n", "<leader>G", "", {
	noremap = true,
	silent = true,
	callback = function()
		require("orgmode").action("org_mappings.insert_todo_heading_respect_content")
		require("orgmode").action("org_mappings.do_demote")
	end,
})

-- Function to always perform a vertical diffsplit
function diff_vertical()
	vim.cmd("vertical diffsplit")
end

-- Set keybindings for common diff functions
keymap = vim.api.nvim_set_keymap
opts = { noremap = true, silent = true }

-- Keybinding for starting a vertical diff split
keymap("n", "<leader>dv", ":lua diff_vertical()<CR>", opts)

-- Keybinding for toggling diff mode
keymap("n", "<leader>dt", ":diffthis<CR>", opts)

-- Keybinding for exiting diff mode
keymap("n", "<leader>du", ":diffoff<CR>", opts)

-- Keybinding for updating diffs
keymap("n", "<leader>dr", ":diffupdate<CR>", opts)

keymap("v", "n", "<C-y,", {})

vim.api.nvim_set_keymap("n", "<leader>ou", ":AerialNavToggle<CR>", { noremap = true, silent = true })

-- Call the setup function to change the default behavior
require("aerial").setup({
	-- Priority list of preferred backends for aerial.
	-- This can be a filetype map (see :help aerial-filetype-map)
	backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },

	layout = {
		-- These control the width of the aerial window.
		-- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
		-- min_width and max_width can be a list of mixed types.
		-- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
		max_width = { 0.9 },
		width = nil,
		min_width = 0.6,

		-- key-value pairs of window-local options for aerial window (e.g. winhl)
		win_opts = {},

		-- Determines the default direction to open the aerial window. The 'prefer'
		-- options will open the window in the other direction *if* there is a
		-- different buffer in the way of the preferred direction
		-- Enum: prefer_right, prefer_left, right, left, float
		default_direction = "float",

		-- Determines where the aerial window will be opened
		--   edge   - open aerial at the far right/left of the editor
		--   window - open aerial to the right/left of the current window
		placement = "window",

		-- When the symbols change, resize the aerial window (within min/max constraints) to fit
		resize_to_content = true,

		-- Preserve window size equality with (:help CTRL-W_=)
		preserve_equality = false,
	},

	-- Determines how the aerial window decides which buffer to display symbols for
	--   window - aerial window will display symbols for the buffer in the window from which it was opened
	--   global - aerial window will display symbols for the current window
	attach_mode = "window",

	-- List of enum values that configure when to auto-close the aerial window
	--   unfocus       - close aerial when you leave the original source window
	--   switch_buffer - close aerial when you change buffers in the source window
	--   unsupported   - close aerial when attaching to a buffer that has no symbol source
	close_automatic_events = {},

	-- Keymaps in aerial window. Can be any value that `vim.keymap.set` accepts OR a table of keymap
	-- options with a `callback` (e.g. { callback = function() ... end, desc = "", nowait = true })
	-- Additionally, if it is a string that matches "actions.<name>",
	-- it will use the mapping at require("aerial.actions").<name>
	-- Set to `false` to remove a keymap
	keymaps = {
		["?"] = "actions.show_help",
		["g?"] = "actions.show_help",
		["<CR>"] = "actions.jump",
		["<2-LeftMouse>"] = "actions.jump",
		["<C-v>"] = "actions.jump_vsplit",
		["<C-s>"] = "actions.jump_split",
		["p"] = "actions.scroll",
		["<C-j>"] = "actions.down_and_scroll",
		["<C-k>"] = "actions.up_and_scroll",
		["{"] = "actions.prev",
		["}"] = "actions.next",
		["[["] = "actions.prev_up",
		["]]"] = "actions.next_up",
		["q"] = "actions.close",
		["o"] = "actions.tree_toggle",
		["za"] = "actions.tree_toggle",
		["O"] = "actions.tree_toggle_recursive",
		["zA"] = "actions.tree_toggle_recursive",
		["l"] = "actions.tree_open",
		["zo"] = "actions.tree_open",
		["L"] = "actions.tree_open_recursive",
		["zO"] = "actions.tree_open_recursive",
		["h"] = "actions.tree_close",
		["zc"] = "actions.tree_close",
		["H"] = "actions.tree_close_recursive",
		["zC"] = "actions.tree_close_recursive",
		["zr"] = "actions.tree_increase_fold_level",
		["zR"] = "actions.tree_open_all",
		["zm"] = "actions.tree_decrease_fold_level",
		["zM"] = "actions.tree_close_all",
		["zx"] = "actions.tree_sync_folds",
		["zX"] = "actions.tree_sync_folds",
	},

	-- When true, don't load aerial until a command or function is called
	-- Defaults to true, unless `on_attach` is provided, then it defaults to false
	lazy_load = true,

	-- Disable aerial on files with this many lines
	disable_max_lines = 10000,

	-- Disable aerial on files this size or larger (in bytes)
	disable_max_size = 2000000, -- Default 2MB

	-- A list of all symbols to display. Set to false to display all symbols.
	-- This can be a filetype map (see :help aerial-filetype-map)
	-- To see all available values, see :help SymbolKind
	filter_kind = {
		"Class",
		"Constructor",
		"Enum",
		"Function",
		"Interface",
		"Module",
		"Method",
		"Struct",
	},

	-- Determines line highlighting mode when multiple splits are visible.
	-- split_width   Each open window will have its cursor location marked in the
	--               aerial buffer. Each line will only be partially highlighted
	--               to indicate which window is at that location.
	-- full_width    Each open window will have its cursor location marked as a
	--               full-width highlight in the aerial buffer.
	-- last          Only the most-recently focused window will have its location
	--               marked in the aerial buffer.
	-- none          Do not show the cursor locations in the aerial window.
	highlight_mode = "split_width",

	-- Highlight the closest symbol if the cursor is not exactly on one.
	highlight_closest = true,

	-- Highlight the symbol in the source buffer when cursor is in the aerial win
	highlight_on_hover = false,

	-- When jumping to a symbol, highlight the line for this many ms.
	-- Set to false to disable
	highlight_on_jump = 300,

	-- Jump to symbol in source window when the cursor moves
	autojump = false,

	-- Define symbol icons. You can also specify "<Symbol>Collapsed" to change the
	-- icon when the tree is collapsed at that symbol, or "Collapsed" to specify a
	-- default collapsed icon. The default icon set is determined by the
	-- "nerd_font" option below.
	-- If you have lspkind-nvim installed, it will be the default icon set.
	-- This can be a filetype map (see :help aerial-filetype-map)
	icons = {},

	-- Control which windows and buffers aerial should ignore.
	-- Aerial will not open when these are focused, and existing aerial windows will not be updated
	ignore = {
		-- Ignore unlisted buffers. See :help buflisted
		unlisted_buffers = false,

		-- Ignore diff windows (setting to false will allow aerial in diff windows)
		diff_windows = true,

		-- List of filetypes to ignore.
		filetypes = {},

		-- Ignored buftypes.
		-- Can be one of the following:
		-- false or nil - No buftypes are ignored.
		-- "special"    - All buffers other than normal, help and man page buffers are ignored.
		-- table        - A list of buftypes to ignore. See :help buftype for the
		--                possible values.
		-- function     - A function that returns true if the buffer should be
		--                ignored or false if it should not be ignored.
		--                Takes two arguments, `bufnr` and `buftype`.
		buftypes = "special",

		-- Ignored wintypes.
		-- Can be one of the following:
		-- false or nil - No wintypes are ignored.
		-- "special"    - All windows other than normal windows are ignored.
		-- table        - A list of wintypes to ignore. See :help win_gettype() for the
		--                possible values.
		-- function     - A function that returns true if the window should be
		--                ignored or false if it should not be ignored.
		--                Takes two arguments, `winid` and `wintype`.
		wintypes = "special",
	},

	-- Use symbol tree for folding. Set to true or false to enable/disable
	-- Set to "auto" to manage folds if your previous foldmethod was 'manual'
	-- This can be a filetype map (see :help aerial-filetype-map)
	manage_folds = false,

	-- When you fold code with za, zo, or zc, update the aerial tree as well.
	-- Only works when manage_folds = true
	link_folds_to_tree = false,

	-- Fold code when you open/collapse symbols in the tree.
	-- Only works when manage_folds = true
	link_tree_to_folds = true,

	-- Set default symbol icons to use patched font icons (see https://www.nerdfonts.com/)
	-- "auto" will set it to true if nvim-web-devicons or lspkind-nvim is installed.
	nerd_font = "auto",

	-- Call this function when aerial attaches to a buffer.
	on_attach = function(bufnr) end,

	-- Call this function when aerial first sets symbols on a buffer.
	on_first_symbols = function(bufnr) end,

	-- Automatically open aerial when entering supported buffers.
	-- This can be a function (see :help aerial-open-automatic)
	open_automatic = false,

	-- Run this command after jumping to a symbol (false will disable)
	post_jump_cmd = "normal! zz",

	-- Invoked after each symbol is parsed, can be used to modify the parsed item,
	-- or to filter it by returning false.
	--
	-- bufnr: a neovim buffer number
	-- item: of type aerial.Symbol
	-- ctx: a record containing the following fields:
	--   * backend_name: treesitter, lsp, man...
	--   * lang: info about the language
	--   * symbols?: specific to the lsp backend
	--   * symbol?: specific to the lsp backend
	--   * syntax_tree?: specific to the treesitter backend
	--   * match?: specific to the treesitter backend, TS query match
	post_parse_symbol = function(bufnr, item, ctx)
		return true
	end,

	-- Invoked after all symbols have been parsed and post-processed,
	-- allows to modify the symbol structure before final display
	--
	-- bufnr: a neovim buffer number
	-- items: a collection of aerial.Symbol items, organized in a tree,
	--        with 'parent' and 'children' fields
	-- ctx: a record containing the following fields:
	--   * backend_name: treesitter, lsp, man...
	--   * lang: info about the language
	--   * symbols?: specific to the lsp backend
	--   * syntax_tree?: specific to the treesitter backend
	post_add_all_symbols = function(bufnr, items, ctx)
		return items
	end,

	-- When true, aerial will automatically close after jumping to a symbol
	close_on_select = false,

	-- The autocmds that trigger symbols update (not used for LSP backend)
	update_events = "TextChanged,InsertLeave",

	-- Show box drawing characters for the tree hierarchy
	show_guides = false,

	-- Customize the characters used when show_guides = true
	guides = {
		-- When the child item has a sibling below it
		mid_item = "├─",
		-- When the child item is the last in the list
		last_item = "└─",
		-- When there are nested child guides to the right
		nested_top = "│ ",
		-- Raw indentation
		whitespace = "  ",
	},

	-- Set this function to override the highlight groups for certain symbols
	get_highlight = function(symbol, is_icon, is_collapsed)
		-- return "MyHighlight" .. symbol.kind
	end,

	-- Options for opening aerial in a floating win
	float = {
		-- Controls border appearance. Passed to nvim_open_win
		border = "rounded",

		-- Determines location of floating window
		--   cursor - Opens float on top of the cursor
		--   editor - Opens float centered in the editor
		--   win    - Opens float centered in the window
		relative = "cursor",

		-- These control the height of the floating window.
		-- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
		-- min_height and max_height can be a list of mixed types.
		-- min_height = {8, 0.1} means "the greater of 8 rows or 10% of total"
		max_height = 0.9,
		height = nil,
		min_height = { 8, 0.1 },

		override = function(conf, source_winid)
			-- This is the config that will be passed to nvim_open_win.
			-- Change values here to customize the layout
			return conf
		end,
	},

	-- Options for the floating nav windows
	nav = {
		border = "rounded",
		max_height = 0.9,
		min_height = { 10, 0.1 },
		max_width = 0.5,
		min_width = { 0.2, 20 },
		win_opts = {
			cursorline = true,
			winblend = 10,
		},
		-- Jump to symbol in source window when the cursor moves
		autojump = false,
		-- Show a preview of the code in the right column, when there are no child symbols
		preview = false,
		-- Keymaps in the nav window
		keymaps = {
			["<CR>"] = "actions.jump",
			["<2-LeftMouse>"] = "actions.jump",
			["<C-v>"] = "actions.jump_vsplit",
			["<C-s>"] = "actions.jump_split",
			["h"] = "actions.left",
			["l"] = "actions.right",
			["<C-c>"] = "actions.close",
		},
	},

	lsp = {
		-- If true, fetch document symbols when LSP diagnostics update.
		diagnostics_trigger_update = false,

		-- Set to false to not update the symbols when there are LSP errors
		update_when_errors = true,

		-- How long to wait (in ms) after a buffer change before updating
		-- Only used when diagnostics_trigger_update = false
		update_delay = 300,

		-- Map of LSP client name to priority. Default value is 10.
		-- Clients with higher (larger) priority will be used before those with lower priority.
		-- Set to -1 to never use the client.
		priority = {
			-- pyright = 10,
		},
	},

	treesitter = {
		-- How long to wait (in ms) after a buffer change before updating
		update_delay = 300,
	},

	markdown = {
		-- How long to wait (in ms) after a buffer change before updating
		update_delay = 300,
	},

	asciidoc = {
		-- How long to wait (in ms) after a buffer change before updating
		update_delay = 300,
	},

	man = {
		-- How long to wait (in ms) after a buffer change before updating
		update_delay = 300,
	},
})

local api = vim.api

api.nvim_set_keymap("n", "<leader>zn", ":TZNarrow<CR>", {})
api.nvim_set_keymap("v", "<leader>zn", ":'<,'>TZNarrow<CR>", {})
api.nvim_set_keymap("n", "<leader>zf", ":TZFocus<CR>", {})
api.nvim_set_keymap("n", "<leader>zm", ":TZMinimalist<CR>", {})
api.nvim_set_keymap("n", "<leader>za", ":TZAtaraxis<CR>", {})

vim.api.nvim_create_autocmd("CompleteDone", {
	callback = function()
		vim.lsp.buf.hover()
	end,
})

vim.api.nvim_create_autocmd("CompleteChanged", {
	callback = function()
		local item = vim.fn.complete_info({ "selected" }).selected
		if item ~= -1 then -- Check if an item is selected
			vim.lsp.buf.hover() -- Trigger hover for the current item
		end
	end,
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "rounded", -- Optional: Customize border style
	focusable = false, -- Prevent focus on hover window
	anchor = "NW", -- Anchor hover window to the top-left of the cursor
	relative = "cursor", -- Position relative to the cursor
	row = -2, -- Shift hover window upwards
	col = 10, -- Shift hover window slightly to the right
})

-- Put this in your Lua config (e.g., in `~/.config/nvim/lua/mybindings.lua`)
vim.keymap.set("n", "<leader>d", function()
	local filepath = vim.fn.expand("%:p") -- Absolute path of current file
	if vim.fn.empty(filepath) == 1 then
		print("No file associated with this buffer.")
		return
	end
	local patchfile = filepath .. ".patch" -- We'll write the diff here
	-- The trick: ":w !diff -u <old> - > <patch>"
	-- ":%:p" is the file on disk (last saved), "-" is the current buffer via stdin
	local cmd = string.format("write !diff -u %s - > %s", vim.fn.shellescape(filepath), vim.fn.shellescape(patchfile))
	vim.cmd(cmd)
	print("Patch created: " .. patchfile)
end, { desc = "Create diff patch of last saved vs. current buffer" })

vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.breakindentopt = "shift:2"
vim.opt.showbreak = "↳ "

vim.g.dispatch_no_tmux_make = 1
vim.g.dispatch_no_job_make = 1

local function create_c_template()
	-- Prompt the user for a directory name.
	local dir = vim.fn.input("Enter directory name: ")
	if dir == "" then
		print("No directory entered.")
		return
	end

	-- Expand home directory and define the target directory.
	local home = vim.fn.expand("~")
	local target_dir = home .. "/test/c/" .. dir

	-- Create the directory (including any parent directories).
	vim.fn.mkdir(target_dir, "p")

	-- Create main.c with the C code template.
	local c_filepath = target_dir .. "/main.c"
	local c_template = [[
/* clang -o main main.c && ./main */
#include <stdio.h>

int main(void) {
    printf("Hello, World!\n");
    return 0;
}
]]
	local c_file = io.open(c_filepath, "w")
	if c_file then
		c_file:write(c_template)
		c_file:close()
		print("C template created at " .. c_filepath)
	else
		print("Error creating file: " .. c_filepath)
		return
	end

	-- Create a Makefile with build instructions.
	local make_filepath = target_dir .. "/Makefile"
	local make_template = "all:\n\tclang -o main main.c\n\t./main\n"
	local make_file = io.open(make_filepath, "w")
	if make_file then
		make_file:write(make_template)
		make_file:close()
		print("Makefile created at " .. make_filepath)
	else
		print("Error creating file: " .. make_filepath)
	end

	-- Open main.c in Neovim.
	vim.cmd("edit " .. c_filepath)
end

-- Map the function to a keybinding (<leader>ot).
vim.api.nvim_set_keymap("n", "<leader>ot", "", { callback = create_c_template, noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "f", [[:lua ProcessAndSetMakeprg()<CR>]], { noremap = true, silent = true })

function ProcessAndSetMakeprg()
	local line = vim.api.nvim_get_current_line()
	vim.api.nvim_buf_add_highlight(0, -1, "Visual", vim.fn.line(".") - 1, 0, -1)

	-- local processed_line = line:match("^%s*(.-)%s*$"):gsub(" ", "\\ ")
	local processed_line = line:gsub("^%s*[#%-/]+%s*","")

	vim.opt.makeprg = processed_line

	print("makeprg set to: " .. processed_line)

	vim.defer_fn(function()
		vim.api.nvim_buf_clear_namespace(0, -1, vim.fn.line(".") - 1, vim.fn.line("."))
	end, 500)
end


-- Helper function to sanitize the dispatch command for safe filename usage.
local function sanitize_command(cmd)
  -- Remove any leading colon and whitespace.
  local sanitized = cmd:gsub("^:%s*", "")
  -- Remove the "Dispatch " prefix.
  sanitized = sanitized:gsub("^Dispatch%s+", "")
  -- Remove any substring in parentheses (e.g., " (neovim/3349296)").
  sanitized = sanitized:gsub("%s*%([^)]*%)", "")
  -- Replace spaces with underscores.
  sanitized = sanitized:gsub("%s+", "_")
  -- Replace any slashes with underscores.
  sanitized = sanitized:gsub("[/\\]", "_")
  return sanitized
end

-- Global function to save the quickfix list to a file.
_G.save_quickfix_to_file = function()
  -- Retrieve the quickfix title and items.
  local qf_info = vim.fn.getqflist({ title = 0, items = 0 })
  local title = qf_info.title or "quickfix"
  
  -- Sanitize the dispatch command; if it ends up empty, default to "quickfix".
  local command = sanitize_command(title)
  if command == "" then
    command = "quickfix"
  end
  
  -- Get the current Unix timestamp.
  local timestamp = tostring(os.time())
  -- Build the filename in the format: timestamp_command.txt
  local filename = string.format("%s_%s.txt", timestamp, command)
  
  -- Determine the output directory using the home directory.
  local home_dir = vim.fn.expand("~/")
  if home_dir == "" then
    home_dir = "/tmp/"
  end
  if home_dir:sub(-1) ~= "/" then
    home_dir = home_dir .. "/"
  end
  local output_file = home_dir .. filename

  -- Build the list of quickfix items.
  local lines = {}
  for _, item in ipairs(qf_info.items) do
    table.insert(lines, item.text or "")
  end

  -- Write the contents to the generated file.
  vim.fn.writefile(lines, output_file)
  print("Quickfix list saved to " .. output_file)
end

-- Bind the global function to <leader>S in normal mode.
vim.api.nvim_set_keymap("n", "<leader>S", "<cmd>lua save_quickfix_to_file()<CR>", { noremap = true, silent = true })
