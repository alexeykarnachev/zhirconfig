-- Basic Neovim Settings
vim.opt.number = true -- Show line numbers
vim.opt.mouse = "a" -- Enable mouse in all modes
vim.opt.showmode = false -- Hide mode display (e.g., -- INSERT --)
vim.opt.clipboard = "unnamedplus" -- Sync clipboard with OS
vim.opt.breakindent = true -- Indent wrapped lines
vim.opt.undofile = true -- Persistent undo
vim.opt.ignorecase = true -- Case-insensitive searching
vim.opt.smartcase = true -- Case-sensitive if uppercase used
vim.opt.signcolumn = "yes" -- Always show sign column
vim.opt.updatetime = 250 -- Faster updates (e.g., for diagnostics)
vim.opt.timeoutlen = 300 -- Time for mapped sequences
vim.g.mapleader = " " -- Leader key set to space
vim.g.have_nerd_font = true -- Enable Nerd Font support
vim.wo.relativenumber = true -- Enable relative line numbers
vim.opt.scrolloff = 8 -- Keep 8 lines above/below cursor for context
vim.opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor

-- Disable unused providers
vim.g.loaded_ruby_provider = 0 -- Disable Ruby
vim.g.loaded_node_provider = 0 -- Disable Node.js
vim.g.loaded_python3_provider = 0 -- Disable Python 3 provider
vim.g.loaded_perl_provider = 0 -- Disable Perl provider

-- Bootstrap Lazy.nvim (Plugin Manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin Setup with Lazy.nvim
require("lazy").setup({
    -- Gruvbox Colorscheme
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = function()
            require("gruvbox").setup({
                contrast = "hard",
                italic = { comments = false },
            })
            vim.cmd.colorscheme("gruvbox")
        end,
    },

    -- Neo-tree (File Explorer)
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        cmd = "Neotree",
        keys = {
            {
                "\\",
                function()
                    local neotree = require("neo-tree.command")
                    local current_win = vim.api.nvim_get_current_win()
                    local current_buf = vim.api.nvim_win_get_buf(current_win)
                    local is_neotree = vim.api.nvim_buf_get_option(current_buf, "filetype") == "neo-tree"

                    if is_neotree then
                        neotree.execute({ action = "close" })
                    else
                        neotree.execute({ action = "show", reveal = false })
                        vim.defer_fn(function()
                            for _, win in ipairs(vim.api.nvim_list_wins()) do
                                local buf = vim.api.nvim_win_get_buf(win)
                                if vim.api.nvim_buf_get_option(buf, "filetype") == "neo-tree" then
                                    vim.api.nvim_set_current_win(win)
                                    break
                                end
                            end
                        end, 50)
                    end
                end,
                desc = "Toggle/Focus Neo-tree",
            },
        },
        opts = {
            close_if_last_window = false,
            popup_border_style = "rounded",
            enable_git_status = true,
            enable_diagnostics = true,
            source_selector = {
                winbar = false,
                statusline = false,
            },
            filesystem = {
                filtered_items = {
                    visible = false,
                    hide_dotfiles = true,
                    hide_gitignored = true,
                    hide_hidden = true,
                },
                follow_current_file = { enabled = true },
                group_empty_dirs = true,
                hijack_netrw_behavior = "open_default",
            },
        },
        init = function()
            vim.api.nvim_create_autocmd("VimEnter", {
                callback = function()
                    if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
                        vim.cmd("Neotree dir=" .. vim.fn.argv(0))
                    end
                end,
            })
        end,
    },

    -- Mason (Tool Installer)
    {
        "williamboman/mason.nvim",
        cmd = { "Mason", "MasonInstall" },
        opts = {
            ui = { border = "rounded" },
            ensure_installed = {
                "stylua",
                "black",
                "lua-language-server",
                "ruff",
                "isort",
                "djlint",
                "html-lsp",
                "htmx-lsp",
                "prettierd",
            },
        },
        config = function(_, opts)
            require("mason").setup(opts)
            local mr = require("mason-registry")
            for _, tool in ipairs(opts.ensure_installed) do
                local p = mr.get_package(tool)
                if not p:is_installed() then
                    p:install()
                end
            end
        end,
    },

    -- LSP Configuration
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local lspconfig = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Shared on_attach function
            local on_attach = function(client, bufnr)
                local opts = { buffer = bufnr, desc = "LSP: " }
                vim.keymap.set(
                    "n",
                    "gd",
                    vim.lsp.buf.definition,
                    vim.tbl_extend("force", opts, { desc = "Goto Definition" })
                )
                vim.keymap.set(
                    "n",
                    "gr",
                    vim.lsp.buf.references,
                    vim.tbl_extend("force", opts, { desc = "Goto References" })
                )
                vim.keymap.set(
                    "n",
                    "<leader>rn",
                    vim.lsp.buf.rename,
                    vim.tbl_extend("force", opts, { desc = "Rename" })
                )
                vim.keymap.set(
                    "n",
                    "<leader>ca",
                    vim.lsp.buf.code_action,
                    vim.tbl_extend("force", opts, { desc = "Code Action" })
                )
                vim.keymap.set("n", "K", function()
                    -- Prefer html-lsp for hover if available
                    local clients = vim.lsp.get_clients({ bufnr = bufnr })
                    for _, c in ipairs(clients) do
                        if c.name == "html" and c.server_capabilities.hoverProvider then
                            local position_encoding = c.offset_encoding or "utf-16"
                            local params = vim.lsp.util.make_position_params(0, position_encoding)
                            vim.lsp.buf_request(bufnr, "textDocument/hover", params, nil)
                            return
                        end
                    end
                    -- Fallback to default hover
                    vim.lsp.buf.hover()
                end, vim.tbl_extend("force", opts, { desc = "Hover Documentation" }))
            end

            local custom_hover_handler = function(err, result, ctx, config)
                if err or not result or not result.contents then
                    return vim.lsp.handlers.hover(err, result, ctx, config)
                end

                local lines = {}
                if type(result.contents) == "table" and result.contents.value then
                    for line in result.contents.value:gmatch("[^\r\n]+") do
                        if not (line:lower():match("%[baseline[_%s]+icon%]") or line:match("data:image/svg")) then
                            table.insert(lines, line)
                        end
                    end
                    result.contents.value = table.concat(lines, "\n")
                elseif type(result.contents) == "string" then
                    for line in result.contents:gmatch("[^\r\n]+") do
                        if not (line:lower():match("%[baseline[_%s]+icon%]") or line:match("data:image/svg")) then
                            table.insert(lines, line)
                        end
                    end
                    result.contents = table.concat(lines, "\n")
                end

                vim.lsp.handlers.hover(err, result, ctx, config)
            end

            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "pyright", "html", "htmx" },
                automatic_installation = true,
                handlers = {
                    function(server_name)
                        lspconfig[server_name].setup({
                            capabilities = capabilities,
                            on_attach = on_attach,
                        })
                    end,
                    ["lua_ls"] = function()
                        lspconfig.lua_ls.setup({
                            capabilities = capabilities,
                            on_attach = on_attach,
                            settings = {
                                Lua = {
                                    runtime = { version = "LuaJIT" },
                                    diagnostics = { globals = { "vim" } },
                                    workspace = {
                                        library = { vim.env.VIMRUNTIME },
                                    },
                                },
                            },
                        })
                    end,
                    ["html"] = function()
                        lspconfig.html.setup({
                            capabilities = vim.tbl_deep_extend("force", capabilities, {
                                textDocument = {
                                    completion = {
                                        completionItem = {
                                            snippetSupport = true,
                                        },
                                    },
                                    hover = {
                                        dynamicRegistration = true,
                                    },
                                },
                            }),
                            on_attach = on_attach,
                            filetypes = { "html", "htmldjango" },
                            settings = {
                                html = {
                                    hover = {
                                        documentation = true,
                                        references = true,
                                    },
                                },
                            },
                            handlers = {
                                ["textDocument/hover"] = custom_hover_handler,
                            },
                        })
                    end,
                    ["htmx"] = function()
                        lspconfig.htmx.setup({
                            capabilities = vim.tbl_deep_extend("force", capabilities, {
                                textDocument = {
                                    hover = nil,
                                },
                            }),
                            on_attach = on_attach,
                            filetypes = { "html", "htmldjango" },
                        })
                    end,
                },
            })

            vim.diagnostic.config({
                virtual_text = true,
                signs = vim.g.have_nerd_font
                        and {
                            text = { [vim.diagnostic.severity.ERROR] = "󰅚", [vim.diagnostic.severity.WARN] = "󰀪" },
                        }
                    or {},
                float = {
                    border = "rounded",
                    source = true,
                    scrollable = true,
                },
            })
        end,
    },

    -- Autocompletion
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                }),
                sources = {
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "path" },
                },
                formatting = {
                    format = function(entry, item)
                        if entry.completion_item.detail ~= nil and entry.completion_item.detail ~= "" then
                            item.menu = entry.completion_item.detail
                        else
                            item.menu = ({
                                nvim_lsp = "[LSP]",
                                luasnip = "[Snippet]",
                                path = "[Path]",
                            })[entry.source.name]
                        end
                        return item
                    end,
                },
            })
        end,
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        main = "nvim-treesitter.configs",
        opts = {
            ensure_installed = {
                "bash",
                "c",
                "diff",
                "html",
                "lua",
                "luadoc",
                "markdown",
                "markdown_inline",
                "query",
                "vim",
                "vimdoc",
                "typescript",
                "javascript",
                "svelte",
            },
            auto_install = true,
            highlight = {
                enable = true,
            },
            indent = { enable = true },
            filetype_to_parsername = {
                htmldjango = "html",
            },
        },
    },

    -- Telescope (Fuzzy Finder)
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Search Files" },
            { "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Search Grep" },
            { "<leader>sb", "<cmd>Telescope buffers<cr>", desc = "Search Buffers" },
        },
        opts = {
            defaults = { mappings = { i = { ["<C-u>"] = false } } },
        },
    },

    -- Conform (Buffer Formatting)
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        keys = {
            {
                "<leader>f",
                function()
                    require("conform").format({ async = true })
                end,
                desc = "Format buffer",
            },
        },
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "ruff_format", "isort" },
                glsl = { "clang-format" },
                svelte = { "prettierd" },
                typescript = { "prettierd" },
                javascript = { "prettierd" },
                html = { "prettierd" },
                css = { "prettierd" },
                htmldjango = { "prettierd", "djlint" },
            },
            formatters = {
                stylua = {
                    command = vim.fn.stdpath("data") .. "/mason/bin/stylua",
                    args = { "--indent-type", "Spaces", "--indent-width", "4", "-" },
                },
                ruff_format = {
                    command = vim.fn.stdpath("data") .. "/mason/bin/ruff",
                    args = { "format", "--line-length", "88", "-" },
                },
                isort = {
                    command = vim.fn.stdpath("data") .. "/mason/bin/isort",
                    args = { "--stdout", "--filename", "$FILENAME", "-" },
                },
                prettierd = {
                    command = vim.fn.stdpath("data") .. "/mason/bin/prettierd",
                    args = {
                        "--print-width=88",
                        "--tab-width=4",
                        "--use-tabs=false",
                        "$FILENAME",
                    },
                },
                djlint = {
                    command = vim.fn.stdpath("data") .. "/mason/bin/djlint",
                    args = { "--reformat", "--indent", "4", "--profile=jinja", "-" },
                    stdin = true,
                },
            },
        },
    },

    -- Linting with nvim-lint
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPost", "BufWritePost", "BufEnter" },
        config = function()
            require("lint").linters_by_ft = { htmldjango = { "djlint" } }
            require("lint").linters.djlint = {
                cmd = vim.fn.stdpath("data") .. "/mason/bin/djlint",
                args = { "--profile=jinja", "--lint", "--quiet", "-" },
                stdin = true,
                stream = "stdout",
                ignore_exitcode = true,
                parser = function(output, bufnr)
                    local diagnostics = {}
                    local pattern = "(%w+)%s+(%d+):(%d+)%s+(.+)"
                    for line in output:gmatch("[^\r\n]+") do
                        local code, lnum, col, msg = line:match(pattern)
                        if code and lnum and col and msg then
                            table.insert(diagnostics, {
                                bufnr = bufnr,
                                lnum = tonumber(lnum) - 1,
                                col = tonumber(col) - 1,
                                end_lnum = tonumber(lnum) - 1,
                                end_col = tonumber(col),
                                message = msg,
                                code = code,
                                severity = vim.diagnostic.severity.ERROR,
                                source = "djlint",
                                user_data = { lint_code = code },
                            })
                        end
                    end
                    return diagnostics
                end,
            }
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "BufEnter" }, {
                callback = function()
                    vim.schedule(function()
                        require("lint").try_lint()
                    end)
                end,
            })
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "htmldjango",
                callback = function(args)
                    local bufnr = args.buf
                    local timer = vim.loop.new_timer()
                    local debounce_ms = 300
                    local function debounced_lint()
                        timer:stop()
                        timer:start(
                            debounce_ms,
                            0,
                            vim.schedule_wrap(function()
                                if vim.api.nvim_buf_is_valid(bufnr) then
                                    require("lint").try_lint(nil, { bufnr = bufnr })
                                end
                            end)
                        )
                    end
                    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave" }, {
                        buffer = bufnr,
                        callback = debounced_lint,
                    })
                end,
            })
        end,
    },

    -- Which-key (Command Pane)
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            delay = 200,
            icons = { mappings = vim.g.have_nerd_font },
        },
        config = function()
            local wk = require("which-key")
            wk.add({
                { "\\", desc = "Toggle/Focus Neo-tree" },
                { "<leader>f", desc = "Format buffer" },
                { "<leader>q", "<cmd>q<cr>", desc = "Quit" },
                { "<leader>w", "<cmd>w<cr>", desc = "Write" },
                { "<leader>d", group = "Diagnostics" },
                { "<leader>df", vim.diagnostic.open_float, desc = "Show Diagnostics" },
                { "<leader>dq", vim.diagnostic.setloclist, desc = "Diagnostic Quickfix" },
                { "<leader>di", desc = "Focus Diagnostic Window" },
                { "<leader>dc", desc = "Close Diagnostic Window" },
                { "<leader>s", group = "Search" },
                { "<leader>sf", desc = "Search Files" },
                { "<leader>sg", desc = "Search Grep" },
                { "<leader>sb", desc = "Search Buffers" },
                { "<leader>l", group = "LSP" },
                { "<leader>ld", vim.lsp.buf.definition, desc = "Goto Definition" },
                { "<leader>lr", vim.lsp.buf.references, desc = "Goto References" },
                { "<leader>ln", vim.lsp.buf.rename, desc = "Rename" },
                { "<leader>la", vim.lsp.buf.code_action, desc = "Code Action" },
                { "[d", desc = "Previous Diagnostic" },
                { "]d", desc = "Next Diagnostic" },
            })
        end,
    },

    -- CodeCompanion (AI Integration)
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("codecompanion").setup({
                adapters = {
                    anthropic = function()
                        return require("codecompanion.adapters").extend("anthropic", {
                            env = {
                                api_key = vim.env.ANTHROPIC_API_KEY,
                            },
                            schema = {
                                model = {
                                    default = "claude-3.5-sonnet",
                                },
                            },
                        })
                    end,
                    openai = function()
                        return require("codecompanion.adapters").extend("openai", {
                            env = {
                                api_key = vim.env.OPENAI_API_KEY,
                            },
                            schema = {
                                model = {
                                    default = "gpt-4o",
                                },
                            },
                        })
                    end,
                    gemini = function()
                        return require("codecompanion.adapters").extend("gemini", {
                            env = {
                                api_key = vim.env.GEMINI_API_KEY,
                            },
                        })
                    end,
                },
                strategies = {
                    chat = {
                        adapter = "anthropic",
                    },
                    inline = {
                        adapter = "anthropic",
                    },
                },
            })
        end,
    },
})

-- Global Diagnostic Keymaps
vim.keymap.set("n", "[d", function()
    vim.diagnostic.goto_prev({ float = { border = "rounded", focusable = true, scope = "cursor" } })
end, { desc = "Previous Diagnostic" })
vim.keymap.set("n", "]d", function()
    vim.diagnostic.goto_next({ float = { border = "rounded", focusable = true, scope = "cursor" } })
end, { desc = "Next Diagnostic" })
vim.keymap.set("n", "<leader>di", function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == "nofile" and vim.api.nvim_win_get_config(win).relative ~= "" then
            vim.api.nvim_set_current_win(win)
            vim.api.nvim_create_autocmd("WinLeave", {
                buffer = buf,
                callback = function()
                    if vim.api.nvim_win_is_valid(win) then
                        vim.api.nvim_win_close(win, true)
                    end
                end,
                once = true,
            })
            return
        end
    end
    print("No diagnostic window available")
end, { desc = "Focus Diagnostic Window" })
vim.keymap.set("n", "<leader>dc", function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == "nofile" and vim.api.nvim_win_get_config(win).relative ~= "" then
            vim.api.nvim_win_close(win, true)
            return
        end
    end
end, { desc = "Close Diagnostic Window" })

-- Filetype Detection for htmldjango
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.html" },
    callback = function()
        vim.bo.filetype = "htmldjango"
    end,
})

-- Basic Keymaps
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to below window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to above window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Use 4 spaces instead of tabs
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "lua", "glsl", "html", "ts", "svelte", "typescript", "htmldjango" },
    callback = function()
        vim.opt_local.expandtab = true
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
        vim.opt_local.softtabstop = 4
    end,
})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 100 })
    end,
    desc = "Highlight yanked text",
})

-- Focus new split when created
vim.api.nvim_set_keymap(
    "n",
    "<C-w>v",
    "<C-w>v<C-w>l",
    { noremap = true, silent = true, desc = "Vertical split and focus" }
)
vim.api.nvim_set_keymap(
    "n",
    "<C-w>s",
    "<C-w>s<C-w>j",
    { noremap = true, silent = true, desc = "Horizontal split and focus" }
)
