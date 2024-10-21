-- Nixvim's internal module table
-- Can be used to share code throughout init.lua
local _M = {}

-- Set up globals {{{
do
    local nixvim_globals = { mapleader = " " }

    for k, v in pairs(nixvim_globals) do
        vim.g[k] = v
    end
end
-- }}}

-- Set up options {{{
do
    local nixvim_options = {
        clipboard = "unnamedplus",
        cursorline = true,
        cursorlineopt = "number",
        expandtab = true,
        fillchars = { eob = " " },
        foldtext = "gitgutter#fold#foldtext",
        ignorecase = true,
        laststatus = 3,
        number = true,
        numberwidth = 2,
        relativenumber = true,
        ruler = false,
        scrolloff = 8,
        shiftwidth = 2,
        signcolumn = "yes",
        smartcase = true,
        smartindent = true,
        softtabstop = 2,
        splitbelow = true,
        splitright = true,
        tabstop = 2,
        timeoutlen = 400,
        undofile = true,
        updatetime = 100,
    }

    for k, v in pairs(nixvim_options) do
        vim.opt[k] = v
    end
end
-- }}}

_onedark = require("onedark")
_onedark.setup({})
_onedark.load()

vim.cmd([[let $BAT_THEME = 'onedark'

colorscheme onedark
]])
local cmp = require("cmp")
cmp.setup({
    mapping = {
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-e>"] = cmp.mapping.close(),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
        ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
    },
    sources = { { name = "nvim_lsp" }, { name = "path" }, { name = "buffer" }, { name = "luasnip" } },
})

require("which-key").setup({})

require("nvim-web-devicons").setup({})

vim.opt.runtimepath:prepend(vim.fs.joinpath(vim.fn.stdpath("data"), "site"))
require("nvim-treesitter.configs").setup({
    auto_install = true,
    ensure_installed = "all",
    highlight = { enable = true },
    parser_install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site"),
})

require("telescope").setup({})

local __telescopeExtensions = {}
for i, extension in ipairs(__telescopeExtensions) do
    require("telescope").load_extension(extension)
end

require("oil").setup({})

require("neoscroll").setup({})

require("lualine").setup({})

require("ibl").setup({ indent = { char = "│" } })

-- LSP {{{
do
    local __lspServers = {
        {
            extraOptions = {
                filetypes = {
                    "javascript",
                    "javascriptreact",
                    "javascript.jsx",
                    "typescript",
                    "typescriptreact",
                    "typescript.tsx",
                },
            },
            name = "ts_ls",
        },
        { name = "rust_analyzer" },
        { name = "lua_ls" },
    }
    -- Adding lspOnAttach function to nixvim module lua table so other plugins can hook into it.
    _M.lspOnAttach = function(client, bufnr) end
    local __lspCapabilities = function()
        capabilities = vim.lsp.protocol.make_client_capabilities()

        capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

        return capabilities
    end

    local __setup = {
        on_attach = _M.lspOnAttach,
        capabilities = __lspCapabilities(),
    }

    for i, server in ipairs(__lspServers) do
        if type(server) == "string" then
            require("lspconfig")[server].setup(__setup)
        else
            local options = server.extraOptions

            if options == nil then
                options = __setup
            else
                options = vim.tbl_extend("keep", options, __setup)
            end

            require("lspconfig")[server.name].setup(options)
        end
    end
end
-- }}}

require("nvim-tree").setup({ hijack_cursor = true, hijack_directories = { auto_open = false } })

-- Set up keybinds {{{
do
    local __nixvim_binds = {
        {
            action = "<cmd>noh<CR>",
            key = "<Esc>",
            mode = "n",
            options = { desc = "clear search highlight", silent = true },
        },
        {
            action = "<leader>/",
            key = "gcc",
            mode = "n",
            options = { desc = "toggle comment", remap = true, silent = true },
        },
        {
            action = "gc",
            key = "<leader>/",
            mode = "v",
            options = { desc = "toggle comment", remap = true, silent = true },
        },
        {
            action = "<cmd>NvimTreeToggle<CR>",
            key = "<C-n>",
            mode = "n",
            options = { desc = "nvimtree toggle window", silent = true },
        },
        {
            action = "<cmd>Telescope find_files<CR>",
            key = "<leader>ff",
            mode = "n",
            options = { desc = "telescope find files", silent = true },
        },
        {
            action = "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
            key = "<leader>fa",
            mode = "n",
            options = { desc = "telescope find all files", silent = true },
        },
        {
            action = "<cmd>Telescope live_grep<CR>",
            key = "<leader>fg",
            mode = "n",
            options = { desc = "Find grep (live grep)", silent = true },
        },
        {
            action = "<C-u>",
            key = "<PageUp>",
            mode = { "n", "i", "v" },
            options = { desc = "scroll up", remap = true, silent = true },
        },
        {
            action = "<C-d>",
            key = "<PageDown>",
            mode = { "n", "i", "v" },
            options = { desc = "scroll down", remap = true, silent = true },
        },
        {
            action = "<cmd>lua vim.lsp.buf.definition()<CR>",
            key = "gd",
            mode = "n",
            options = { desc = "Go to definition" },
        },
        {
            action = "<cmd>lua vim.lsp.buf.declaration()<CR>",
            key = "gD",
            mode = "n",
            options = { desc = "Go to declaration" },
        },
        {
            action = "<cmd>lua vim.lsp.buf.rename()<CR>",
            key = "cd",
            mode = "n",
            options = { desc = "Change definition (rename symbol)" },
        },
    }
    for i, map in ipairs(__nixvim_binds) do
        vim.keymap.set(map.mode, map.key, map.action, map.options)
    end
end
-- }}}

-- Set up autogroups {{
do
    local __nixvim_autogroups = { nixvim_binds_LspAttach = { clear = true } }

    for group_name, options in pairs(__nixvim_autogroups) do
        vim.api.nvim_create_augroup(group_name, options)
    end
end
-- }}
-- Set up autocommands {{
do
    local __nixvim_autocommands = {
        {
            command = "if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif",
            event = "BufEnter",
            nested = true,
        },
        {
            callback = function()
                do
                    local __nixvim_binds = {}
                    for i, map in ipairs(__nixvim_binds) do
                        vim.keymap.set(map.mode, map.key, map.action, map.options)
                    end
                end
            end,
            desc = "Load keymaps for LspAttach",
            event = "LspAttach",
            group = "nixvim_binds_LspAttach",
        },
    }

    for _, autocmd in ipairs(__nixvim_autocommands) do
        vim.api.nvim_create_autocmd(autocmd.event, {
            group = autocmd.group,
            pattern = autocmd.pattern,
            buffer = autocmd.buffer,
            desc = autocmd.desc,
            callback = autocmd.callback,
            command = autocmd.command,
            once = autocmd.once,
            nested = autocmd.nested,
        })
    end
end
-- }}
