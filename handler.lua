-- local cjson = require "cjson.safe"  -- using cjson.safe for safe JSON parsing

local plugin = {
  PRIORITY = 1000,  -- set the plugin priority
  VERSION = "0.1",  -- version in X.Y.Z format
}

function plugin:init_worker()
  kong.log.debug("saying hi from the 'init_worker' handler")
end

-- Helper function to validate JSON structure
local function validate_json(json, config, depth)
  depth = depth or 1

  if depth > config.maxContainerDepth then
    return false, "JSON exceeds maximum container depth"
  end

  if type(json) == "table" then
    local is_array = (#json > 0)

    if is_array and #json > config.maxArrayElementCount then
      return false, "JSON array exceeds maximum element count"
    end
    local objCount = 0
    for key,value in pairs(json) do 
      kong.log.err("--$",key,value)
      objCount =  objCount+1
    end
    if objCount > config.maxObjectEntryCount then
      return false, "JSON object exceeds maximum entry count"
    end

    for key, value in pairs(json) do
      if not is_array and #key > config.maxObjectEntryNameLength then
        return false, "JSON object entry name exceeds maximum length"
      end

      if type(value) == "string" and #value > config.maxStringValueLength then
        return false, "JSON string value exceeds maximum length"
      end

      if type(value) == "table" then
        local valid, err = validate_json(value, config, depth + 1)
        if not valid then
          return false, err
        end
      end
    end
  end

  return true
end

function plugin:access(plugin_conf)
  kong.log.inspect(plugin_conf)

  local body, err = kong.request.get_body()
  if err then
    return kong.response.exit(400, { message = "Invalid JSON payload" })
  end

  local valid, validation_error = validate_json(body, plugin_conf)
  if not valid then
    return kong.response.exit(400, { message = validation_error })
  end
end

return plugin
