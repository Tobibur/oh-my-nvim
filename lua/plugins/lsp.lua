return {
	-- Mason: external tool + LSP server installer
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
					border = "rounded",
				},
			})
		end,
	},

	-- Mason + LSPConfig bridge
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "neovim/nvim-lspconfig" },
		config = function()
			local mason_lspconfig = require("mason-lspconfig")

			mason_lspconfig.setup({
				ensure_installed = { "lua_ls", "pyright", "ts_ls" }, -- add your servers
				automatic_installation = true,
			})

			local lspconfig = require("lspconfig")
			local capabilities = vim.lsp.protocol.make_client_capabilities()

			-- optional: improve completion with nvim-cmp
			-- local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local on_attach = function(client, bufnr)
				-- example keymaps
				local opts = { noremap = true, silent = true, buffer = bufnr }
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
			end

			for _, server in ipairs(mason_lspconfig.get_installed_servers()) do
				lspconfig[server].setup({
					on_attach = on_attach,
					capabilities = capabilities,
				})
			end
		end,
	},

	-- Core LSPConfig (extra configs go here)
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- If you have per-server config, load it here
			-- require("plugins/lspconfig/config")()
		end,
	},

	-- null-ls (formatters, linters, code actions)
	{
		"nvimtools/none-ls.nvim", -- 👈 new official fork of null-ls
		dependencies = { "nvim-lua/plenary.nvim", "nvimtools/none-ls-extras.nvim" },
		config = function()
			local null_ls = require("null-ls")

			local formatting = null_ls.builtins.formatting
			local diagnostics = null_ls.builtins.diagnostics
			local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

			null_ls.setup({
				sources = {
					formatting.stylua,
					formatting.prettier,
					formatting.shfmt,
					require("none-ls.diagnostics.eslint_d"),
				},
				on_attach = function(client, bufnr)
					if client.supports_method("textDocument/formatting") then
						vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = vim.api.nvim_create_augroup("LspFormatting", {}),
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.format({ bufnr = bufnr })
							end,
						})
					end
				end,
			})
		end,
	},

	-- Mason + null-ls bridge
	{
		"jay-babu/mason-null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"nvimtools/none-ls.nvim", -- 👈 updated dependency
		},
		config = function()
			require("mason-null-ls").setup({
				ensure_installed = { "stylua", "prettier", "shfmt" },
				automatic_installation = true,
				handlers = {},
			})
		end,
	},
}
