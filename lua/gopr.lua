local vim = vim

local function run(command)
  local handle = io.popen(command)
  local result = handle:read("*a")
  local status = handle:close()

  return string.gsub(result, '\n', '')
end

function exists(path)
   local f = io.open(path, "r")

   if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

local function gopr()
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

  -- detect pr number
  local commit_range = commit_hash .. '...HEAD'
  local pr_number = run('git log --merges --oneline --reverse --ancestry-path ' .. commit_range .. ' | grep -o "#[0-9]*" -m 1 | sed s/#//g')

  -- detect remote url
  local git_remote_url = run('git config --get remote.upstream.url | sed -E "s/\\.git//"')

  if #pr_number <= 0 or #git_remote_url <= 0 then
    print('fatal: could not find pr or remote url')
    return
  end

  -- open pull request
  os.execute('open ' .. git_remote_url .. '/pull/' .. pr_number)
end

return {
  gopr = gopr
}
