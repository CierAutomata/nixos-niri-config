 local M = {}

 function M.setup()
   require('base16-colorscheme').setup {
     -- Background tones
     base00 = '#171214', -- Default Background
     base01 = '#241e20', -- Lighter Background (status bars)
     base02 = '#2e282a', -- Selection Background
     base03 = '#9d8c91', -- Comments, Invisibles
     -- Foreground tones
     base04 = '#d4c2c7', -- Dark Foreground (status bars)
     base05 = '#ebe0e2', -- Default Foreground
     base06 = '#ebe0e2', -- Light Foreground
     base07 = '#ebe0e2', -- Lightest Foreground
     -- Accent colors
     base08 = '#ffb4ab', -- Variables, XML Tags, Errors
     base09 = '#f1bb97', -- Integers, Constants
     base0A = '#e1bdc9', -- Classes, Search Background
     base0B = '#ffb0d0', -- Strings, Diff Inserted
     base0C = '#f1bb97', -- Regex, Escape Chars
     base0D = '#ffb0d0', -- Functions, Methods
     base0E = '#e1bdc9', -- Keywords, Storage
     base0F = '#93000a', -- Deprecated, Embedded Tags
   }
 end

 -- Register a signal handler for SIGUSR1 (matugen updates)
 local signal = vim.uv.new_signal()
 signal:start(
   'sigusr1',
   vim.schedule_wrap(function()
     package.loaded['matugen'] = nil
     require('matugen').setup()
   end)
 )

 return M
