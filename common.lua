-- Convenience Lua functions that can be used within rpm macros

-- Set a spec variable
-- Echo the result if verbose
local function explicitset(rpmvar,value,verbose)
  local value = value
  if (value == nil) or (value == "") then
    value = "%{nil}"
  end
  rpm.define(rpmvar .. " " .. value)
  if verbose then
    rpm.expand("%{echo:Setting %%{" .. rpmvar .. "} = " .. value .. "}")
  end
end

-- Unset a spec variable if it is defined
-- Echo the result if verbose
local function explicitunset(rpmvar,verbose)
  if (rpm.expand("%{" .. rpmvar .. "}") ~= "%{" .. rpmvar .. "}") then
    rpm.define(rpmvar .. " %{nil}")
    if verbose then
      rpm.expand("%{echo:Unsetting %%{" .. rpmvar .. "}}")
    end
  end
end

-- Set a spec variable, if not already set
-- Echo the result if verbose
local function safeset(rpmvar,value,verbose)
  if (rpm.expand("%{" .. rpmvar .. "}") == "%{" .. rpmvar .. "}") then
    explicitset(rpmvar,value,verbose)
  end
end

-- Alias a list of rpm variables to the same variables suffixed with 0 (and vice versa)
-- Echo the result if verbose
local function zalias(rpmvars,verbose)
  for _, sfx in ipairs({{"","0"},{"0",""}}) do
    for _, rpmvar in ipairs(rpmvars) do
      local toalias = "%{?" .. rpmvar .. sfx[1] .. "}"
      if (rpm.expand(toalias) ~= "") then
        safeset(rpmvar .. sfx[2], toalias, verbose)
      end
    end
  end
end

-- Echo the list of rpm variables, with suffix, if set
local function echovars(rpmvars, suffix)
  for _, rpmvar in ipairs(rpmvars) do
    rpmvar = rpmvar .. suffix
    local header = string.sub("  " .. rpmvar .. ":                                               ",1,21)
    rpm.expand("%{?" .. rpmvar .. ":%{echo:" .. header .. "%{?" .. rpmvar .. "}}}")
  end
end

-- Returns an array, indexed by suffix, containing the non-empy values of
-- <rpmvar><suffix>, with suffix an integer string or the empty string
local function getsuffixed(rpmvar)
  local suffixes = {}
  zalias({rpmvar})
  for suffix=0,9999 do
    local value = rpm.expand("%{?" .. rpmvar .. suffix .. "}")
    if (value ~= "") then
      suffixes[tostring(suffix)] = value
    end
  end
  -- rpm convention is to alias no suffix to zero suffix
  -- only add no suffix if zero suffix is different
  local value = rpm.expand("%{?" .. rpmvar .. "}")
  if (value ~= "") and (value ~= suffixes["0"]) then
     suffixes[""] = value
  end
  return suffixes
end

-- Returns the list of suffixes, including the empty string, for which
-- <rpmvar><suffix> is set to a non empty value
local function getsuffixes(rpmvar)
  suffixes = {}
  for suffix in pairs(getsuffixed(rpmvar)) do
    table.insert(suffixes,suffix)
  end
  table.sort(suffixes,
             function(a,b) return (tonumber(a) or 0) < (tonumber(b) or 0) end)
  return suffixes
end

-- Returns the suffix for which <rpmvar><suffix> has a non-empty value that
-- matches best the beginning of the value string
local function getbestsuffix(rpmvar, value)
  local best         = nil
  local currentmatch = ""
  for suffix, setvalue in pairs(getsuffixed(rpmvar)) do
  if (string.len(setvalue) > string.len(currentmatch)) and
     (string.find(value, "^" .. setvalue)) then
      currentmatch = setvalue
      best         = suffix
    end
  end
  return best
end

return {
  explicitset   = explicitset,
  explicitunset = explicitunset,
  safeset       = safeset,
  zalias        = zalias,
  echovars      = echovars,
  getsuffixed   = getsuffixed,
  getsuffixes   = getsuffixes,
  getbestsuffix = getbestsuffix,
}
