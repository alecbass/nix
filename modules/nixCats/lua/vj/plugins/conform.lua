return {
  { -- Autoformat
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable format on save for specific filetypes
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        -- Lua
        lua = { 'stylua' },
        -- Python
        python = { 'isort', 'black' },
        -- Web development
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        javascriptreact = { 'prettier' },
        typescriptreact = { 'prettier' },
        svelte = { 'prettier' },
        css = { 'prettier' },
        html = { 'prettier', 'djlint' },
        json = { 'prettier' },
        yaml = { 'prettier', 'yamlfmt' },
        graphql = { 'prettier' },
        markdown = { 'prettier' },
        -- System languages
        rust = { 'rustfmt' },
        go = { 'gopls' },
        -- Shell scripting
        sh = { 'shfmt', 'shellharden', 'beautysh' },
        bash = { 'shfmt', 'shellharden', 'beautysh' },
        zsh = { 'shfmt', 'shellharden', 'beautysh' },
        -- Configuration files
        nix = { 'alejandra', 'nixfmt' },
        toml = { 'taplo' },
        -- Databases
        sql = { 'pgformatter' },
      },

      -- Formatter-specific configurations
      formatters = {
        prettier = {
          options = {
            arrow_parens = 'always',
            bracket_spacing = true,
            bracket_same_line = false,
            embedded_language_formatting = 'auto',
            end_of_line = 'lf',
            html_whitespace_sensitivity = 'css',
            jsx_bracket_same_line = false,
            jsx_single_quote = false,
            print_width = 80,
            prose_wrap = 'preserve',
            quote_props = 'as-needed',
            semi = true,
            single_quote = false,
            tab_width = 2,
            trailing_comma = 'es5',
            use_tabs = false,
            stop_after_first = true,
          },
        },
        shfmt = {
          options = {
            indent = 2,
            binary_next_line = true,
            switch_case_indent = true,
            space_redirects = true,
            keep_padding = true,
            func_next_line = false,
            language_variant = 'bash',
          },
        },
        alejandra = {},
        black = {
          options = {
            line_length = 88,
            preview = true,
          },
        },
        isort = {
          options = {
            line_length = 88,
            multi_line_output = 3,
            include_trailing_comma = true,
            force_grid_wrap = 0,
            use_parentheses = true,
            ensure_newline_before_comments = true,
          },
        },
        stylua = {
          options = {
            column_width = 120,
            line_endings = 'Unix',
            indent_type = 'Spaces',
            indent_width = 2,
            quote_style = 'AutoPreferDouble',
            no_call_parentheses = false,
          },
        },
        yamlfmt = {
          options = {
            indent = 2,
            line_ending = 'lf',
            keep_quotes = true,
          },
        },
        pgformatter = {
          options = {
            function_case = 2,
            keyword_case = 2,
            spaces = 2,
            comma_break = true,
            comma_end = false,
          },
        },
      },
    },
  },
}
