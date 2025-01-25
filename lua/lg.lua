local M = {}

local state = {
   floating = {
      buf = -1,
      win = -1,
   },
}

local defaults = {
   winconfig = {
      relative = "editor",
      style = "minimal",
      border = {" ", " ", " ", " ", " ", " ", " ", " "}
   },
   buf = state.floating.buf,
}

local options = {}

M.setup = function(opts)
   options = vim.tbl_deep_extend("force", defaults, opts or {})
end

local function create_floating_window(opts)
   opts = opts or {}

   opts.winconfig.width = opts.winconfig.width or math.floor(vim.o.columns * 0.9)
   opts.winconfig.height = opts.winconfig.height or math.floor(vim.o.lines * 0.9)

   -- Calculate the position to center the window
   opts.winconfig.col = opts.winconfig.col or math.floor((vim.o.columns - opts.winconfig.width) / 2)
   opts.winconfig.row = opts.winconfig.row or math.floor((vim.o.lines - opts.winconfig.height) / 2)

   -- Create a buffer
   local buf = nil
   if vim.api.nvim_buf_is_valid(opts.buf) then
      buf = opts.buf
   else
      buf = vim.api.nvim_create_buf(false, true)
   end

   -- Create the floating window
   local win = vim.api.nvim_open_win(buf, true, opts.winconfig)
   vim.cmd.startinsert()

   return { buf = buf, win = win }
end

local lg_keymap = function(mode, key, callback)
   vim.keymap.set(mode, key, callback, {
      buffer = state.floating.buf,
   })
end

M.toggle = function()
   if not vim.api.nvim_win_is_valid(state.floating.win) then
      state.floating = create_floating_window(options)
      if vim.bo[state.floating.buf].buftype ~= "terminal" then
         vim.cmd.term()
         vim.cmd.startinsert()

         local job_id = 0

         lg_keymap("t", "q", function()
            vim.api.nvim_win_hide(state.floating.win)
         end)

         job_id = vim.bo.channel

         vim.fn.chansend(job_id, { "lazygit", "" })
      end
   else
      vim.api.nvim_win_hide(state.floating.win)
   end
end

return M
