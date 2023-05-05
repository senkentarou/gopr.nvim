local vim = vim

local DEFAULT_OPTIONS = {
  default_remote = 'origin',
}

local function run(command)
  local handle = io.popen(command)
  if handle then
    local result = handle:read("*a")
    handle:close()

    return string.gsub(result, '\n', ' ')
  end

  return ''
end

local function current_commit_hash()
  -- detect commit hash on current line
  local current_file = vim.fn.expand("%")
  local current_line = vim.fn.line('.')
  if #current_file <= 0 or current_line <= 0 then
    vim.notify('fatal: could not find file or line.', vim.log.levels.ERROR)
    return
  end

  local blame_hash = string.gsub(run('git blame -L ' .. current_line .. ',' .. current_line .. ' ' .. current_file .. ' | cut -d\' \' -f1'), '[^0-9a-f]', '')
  if string.find(blame_hash, '^0+$') then
    vim.notify('fatal: current line is not commited yet.', vim.log.levels.ERROR)
    return
  end

  return string.gsub(run('git log --pretty=%H -1 ' .. blame_hash), '%s+', '')
end

local function remote_base_url(args)
  local target_remote = vim.g.gopr.default_remote
  if args and args.remote ~= nil and #args.remote > 0 then
    target_remote = args.remote
  end

  local git_remotes = run('git remote show')
  if not string.find(git_remotes, target_remote) then
    target_remote = DEFAULT_OPTIONS.default_remote
  end

  local git_remote_url = run('git ls-remote --get-url ' .. target_remote)
  local url_base = string.gsub(git_remote_url, '^.-github.com[:/]?(.*)%.git%s?$', '%1')
  if git_remote_url == url_base or #url_base <= 0 then
    vim.notify('fatal: could not open remote url about \'' .. git_remote_url .. '\'', vim.log.levels.ERROR)
    return
  end

  return url_base
end

--
-- Git open pull request
--
local gopr = {}

function gopr.setup(options)
  vim.g.gopr = vim.tbl_deep_extend('force', DEFAULT_OPTIONS, options)
end

-- open pull request directly
function gopr.open_git_pull_request(args)
  local target_commit = current_commit_hash()

  local target_pr = string.gsub(run('git log --merges --oneline --reverse --ancestry-path ' .. target_commit .. '...HEAD' .. ' | grep -o "#[0-9]*" -m 1 | sed s/#//g'), '%s+', '')
  if #target_pr == 0 then
    vim.notify('fatal: could not detect pull request number.', vim.log.levels.ERROR)
    return
  end

  local target_remote = remote_base_url(args)

  local target_url = 'https://github.com/' .. target_remote .. '/pull/' .. target_pr

  os.execute('open ' .. target_url)
  vim.notify('opened: ' .. target_url .. ' on ' .. target_commit)
end

-- open commit diff (and open pull request manually)
function gopr.open_git_commit_diff(args)
  local target_commit = current_commit_hash()

  local target_remote = remote_base_url(args)

  local target_url = 'https://github.com/' .. target_remote .. '/commit/' .. target_commit

  os.execute('open ' .. target_url)
  vim.notify('opened: ' .. target_url)
end

return gopr
