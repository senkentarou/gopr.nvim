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

local function exists(path)
  local f = io.open(path, "r")

  if f ~= nil then
    io.close(f)
    return true
  end

  return false
end

local function current_commit_hash()
  -- detect commit hash on current line
  local current_file = vim.fn.expand("%")
  local current_line = vim.fn.line('.')
  if #current_file <= 0 or current_line <= 0 then
    return
  end

  local blame_hash = string.gsub(run('git blame -L ' .. current_line .. ',' .. current_line .. ' ' .. current_file .. ' | cut -d\' \' -f1'), '[^0-9a-f]', '')
  if string.find(blame_hash, '^0+$') then
    return
  end

  return string.gsub(run('git log --pretty=%H -1 ' .. blame_hash), '%s+', '')
end

local function remote_base_url(args)
  -- detect remote (origin / upstream / etc...)
  local target_remote = vim.g.gopr.default_remote
  if args and args.remote ~= nil and #args.remote > 0 then
    target_remote = args.remote
  end

  local git_remotes = run('git remote show')
  if not string.find(git_remotes, target_remote) then
    target_remote = DEFAULT_OPTIONS.default_remote
  end

  -- get remote base url
  local git_remote_url = run('git ls-remote --get-url ' .. target_remote)
  local url_base = string.gsub(git_remote_url, '^.-github.com[:/]?(.-)%s?$', '%1') -- only github...
  local remote_base = string.gsub(url_base, '^(.-)%.git$', '%1') -- clean .git postfix

  if git_remote_url == remote_base or #remote_base <= 0 then
    return
  end

  return remote_base
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
  -- check .git repository
  if not exists('.git') then
    vim.notify('fatal: .git repository does not exist.', vim.log.levels.ERROR)
    return
  end

  local target_commit = current_commit_hash()
  local target_remote = remote_base_url(args)
  if target_commit == nil or target_remote == nil then
    vim.notify('fatal: could not open remote url. { target_commit=' .. tostring(target_commit) .. ', target_remote=' .. tostring(target_remote) .. ' }.', vim.log.levels.ERROR)
    return
  end

  local target_pr = string.gsub(run('git log --merges --oneline --reverse --ancestry-path ' .. target_commit .. '...HEAD' .. ' | grep -o "#[0-9]*" -m 1 | sed s/#//g'), '%s+', '')
  if #target_pr == 0 then
    vim.notify('fatal: could not detect pull request number.', vim.log.levels.ERROR)
    return
  end

  local target_url = 'https://github.com/' .. target_remote .. '/pull/' .. target_pr

  os.execute('open ' .. target_url)
  vim.notify('opened: ' .. target_url .. ' on ' .. target_commit)
end

-- open commit diff (and open pull request manually)
function gopr.open_git_commit_diff(args)
  -- check .git repository
  if not exists('.git') then
    vim.notify('fatal: .git repository does not exist.', vim.log.levels.ERROR)
    return
  end

  local target_commit = current_commit_hash()
  local target_remote = remote_base_url(args)
  if target_commit == nil or target_remote == nil then
    vim.notify('fatal: could not open remote url. { target_commit=' .. tostring(target_commit) .. ', target_remote=' .. tostring(target_remote) .. ' }.', vim.log.levels.ERROR)
    return
  end

  local target_url = 'https://github.com/' .. target_remote .. '/commit/' .. target_commit

  os.execute('open ' .. target_url)
  vim.notify('opened: ' .. target_url)
end

return gopr
