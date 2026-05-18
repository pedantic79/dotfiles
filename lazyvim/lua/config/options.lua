-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.listchars = { tab = "⇥ ", trail = "·", precedes = "«", extends = "»", eol = "¬" }
vim.opt.colorcolumn = "81,121"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.api.nvim_create_user_command("Hidechars", function()
  vim.o.signcolumn = vim.o.signcolumn == "yes" and "no" or "yes"
  vim.o.list = not vim.o.list
  vim.o.relativenumber = not vim.o.relativenumber
  vim.o.number = not vim.o.number
  vim.cmd.IBLToggle()
end, {})

-- osc52 SSH/override
local function terminal_supports_osc52()
  -- Common terminal identifiers that support OSC 52 out of the box
  local term = vim.env.TERM or ""
  local term_program = vim.env.TERM_PROGRAM or ""
  local lc_terminal = vim.env.LC_TERMINAL

  if term_program == "Apple_Terminal" then
    return false -- Native macOS Terminal famously does NOT support OSC 52
  end

  -- Also support using ~/.config/container
  if vim.uv.fs_stat(vim.fn.expand("~/.config/container")) ~= nil then
    -- assume we're running in a valid terminal
    return true
  end

  if vim.env.TMUX or term_program == "tmux" then
    -- Assume we're running a valid terminal
    return true
  end

  -- If we get to this point, where we are not in a special container or tmux
  -- then don't enable if we aren't in SSH
  if not vim.env.SSH_CONNECTION then
    return false
  end

  -- At this point we are in SSH, and we should check our
  -- Catch-all for modern GPU/advanced terminal emulators
  -- I don't know if Alacritty or WezTerm work
  local modern_terms = { "kitty", "Alacritty", "WezTerm", "Ghostty", "iTerm2" }
  for _, t in ipairs(modern_terms) do
    if term_program == t or lc_terminal == t or term:find(t:lower()) then
      return true
    end
  end

  return false
end

-- Only sync clipboard if the terminal can handle the escape sequences
if terminal_supports_osc52() then
  vim.g.clipboard = "osc52"
  vim.o.clipboard = "unnamedplus"
end
