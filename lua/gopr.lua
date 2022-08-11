local vim = vim

local function run(command)
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()

  return string.gsub(result, '\n', ' ')
end

local function exists(path)
   local f = io.open(path, "r")

   if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

local DEFAULT_OPTIONS = {
  remote_base_url = 'github.com',
  default_remote = 'origin'
}

local gopr = {}

function gopr.setup(options)
  vim.g.gopr = vim.tbl_deep_extend('force', DEFAULT_OPTIONS, options)
end

function gopr.open_git_pull_request(args)
  -- check .git repository
  if not exists('.git') then
    print('fatal: .git repository does not exist.')
    return
  end

  -- detect commit hash on current line
  local current_file = vim.fn.expand("%")
  local current_line = vim.fn.line('.')
  if #current_file <= 0 or current_line <= 0 then
    print('fatal: could not find file or line.')
    return
  end

  local blame_hash = run('git blame -L ' .. current_line .. ',' .. current_line .. ' ' .. current_file .. ' | cut -d\' \' -f1')
  local commit_hash = string.gsub(blame_hash, '[^0-9a-f]', '')
  if string.find(commit_hash, '^0+$') then
    print('fatal: current line is not commited yet.')
    return
  end

  -- detect pr number
  local commit_range = commit_hash .. '...HEAD'
  local detect_merged_pr = run('git log --merges --oneline --reverse --ancestry-path ' .. commit_range .. ' | grep -o "#[0-9]*" -m 1 | sed s/#//g')
  local pr_number = string.gsub(detect_merged_pr, '%s+', '')

  -- detect remote url
  local target_remote = vim.g.gopr.default_remote
  if args and #args.remote > 0 then
    target_remote = args.remote
  end

  local git_remotes = run('git remote show')
  if not string.find(git_remotes, target_remote) then
    target_remote = DEFAULT_OPTIONS.default_remote
  end

  -- support with https or ssh url.
  -- e.g.)
  --  https://github.com/senkentarou/gopr.nvim.git => senkentarou/gopr.nvim
  --  git@github.com:senkentarou/gopr.nvim.git     => senkentarou/gopr.nvim
  local git_remote_url = run('git ls-remote --get-url ' .. target_remote)
  local url_base = string.gsub(git_remote_url, '^.-' .. vim.g.gopr.remote_base_url .. '[:/]?(.*)%.git%s?$', '%1')
  if #pr_number <= 0 or git_remote_url == url_base or #url_base <= 0 then
    print('fatal: could not find pr or remote url by commit hash: ' .. commit_hash)
    return
  end

  -- open pull request
  local target_url = 'https://' .. vim.g.gopr.remote_base_url .. '/' .. url_base .. '/pull/' .. pr_number
  os.execute('open ' .. target_url)

  print('opened: ' .. target_url .. ' on ' .. commit_hash)
end

return gopr
