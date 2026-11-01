local M = {}

M.config = { directory = "~/tasks" }

function M.setup(opts)
  M.config = vim.tbl_extend("force", M.config, opts or {})
end

-- A known section heading on its own line starts the next field.
function M.parse(lines)
  local meta, memo = {}, {}
  local section, pending = nil, false
  local keys = { ["Title"] = true, ["Memo"] = true, ["Due"] = true, ["Duration"] = true }
  for _, line in ipairs(lines) do
    local heading = line:match("^%s*%[(.-)%]%s*$")
    if heading and keys[heading] then
      section = heading
      pending = section ~= "Memo"
      if section ~= "Memo" then
        meta[section] = ""
      end
    elseif section == "Memo" then
      memo[#memo + 1] = line
    elseif pending then
      meta[section] = vim.trim(line)
      pending = false
    end
  end
  return { meta = meta, memo = table.concat(memo, "\n") }
end

return M

