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
            { "\\", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
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
            ensure_installed = { "stylua", "black", "lua-language-server", "ruff" },
        },
        config = function(_, opts)
            require("mason").setup(opts)
            local mr = require("mason-registry")
            for _, tool in ipairs(opts.ensure_installed) do
                local p = mr.get_package(tool)
                if not p:is_installed() then
                    p:install():get_receipt() -- Synchronous install
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

            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "ruff" },
                automatic_installation = true,
                handlers = {
                    function(server_name)
                        lspconfig[server_name].setup({
                            capabilities = capabilities,
                            on_attach = function(_, bufnr)
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
                            end,
                        })
                    end,
                    ["lua_ls"] = function()
                        lspconfig.lua_ls.setup({
                            capabilities = capabilities,
                            on_attach = function(_, bufnr)
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
                            end,
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
                },
            })

            -- Diagnostic config
            vim.diagnostic.config({
                virtual_text = true,
                signs = vim.g.have_nerd_font
                        and {
                            text = { [vim.diagnostic.severity.ERROR] = "󰅚", [vim.diagnostic.severity.WARN] = "󰀪" },
                        }
                    or {},
                float = { border = "rounded" },
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
                    { name = "buffer" },
                    { name = "path" },
                },
            })
        end,
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            ensure_installed = { "lua", "python", "vim", "vimdoc" },
            highlight = { enable = true },
            indent = { enable = true },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
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
                python = { "black" },
            },
            formatters = {
                stylua = {
                    command = vim.fn.stdpath("data") .. "/mason/bin/stylua",
                    args = { "--indent-type", "Spaces", "--indent-width", "4", "-" },
                },
                black = {
                    command = vim.fn.stdpath("data") .. "/mason/bin/black",
                },
            },
        },
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
                { "\\", desc = "Toggle Neo-tree" },
                { "<leader>f", desc = "Format buffer" },
                { "<leader>q", "<cmd>q<cr>", desc = "Quit" },
                { "<leader>w", "<cmd>w<cr>", desc = "Write" },
                { "<leader>d", group = "Diagnostics" },
                { "<leader>df", vim.diagnostic.open_float, desc = "Show Diagnostics" },
                { "<leader>dq", vim.diagnostic.setloclist, desc = "Diagnostic Quickfix" },
                { "<leader>s", group = "Search" },
                { "<leader>sf", desc = "Search Files" },
                { "<leader>sg", desc = "Search Grep" },
                { "<leader>sb", desc = "Search Buffers" },
                { "<leader>l", group = "LSP" },
                { "<leader>ld", vim.lsp.buf.definition, desc = "Goto Definition" },
                { "<leader>lr", vim.lsp.buf.references, desc = "Goto References" },
                { "<leader>ln", vim.lsp.buf.rename, desc = "Rename" },
                { "<leader>la", vim.lsp.buf.code_action, desc = "Code Action" },
            })
        end,
    },
}, {
    -- Lazy options
    ui = { border = "rounded" },
})

-- Basic Keymaps
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to below window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to above window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Use 4 spaces instead of tabs for Lua
vim.api.nvim_create_autocmd("FileType", {
    pattern = "lua",
    callback = function()
        vim.opt_local.expandtab = true
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
        vim.opt_local.softtabstop = 4
    end,
})
