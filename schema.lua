-- local typedefs = require "kong.db.schema.typedefs"

return {
  name = "myplugin",
  fields = {
    { config = {
        type = "record",
        fields = {
          { maxArrayElementCount = { type = "integer", default = 0, required = false } },
          { maxContainerDepth = { type = "integer", default = 0, required = false } },
          { maxObjectEntryCount = { type = "integer", default = 0, required = false } },
          { maxObjectEntryNameLength = { type = "integer", default = 0, required = false } },
          { maxStringValueLength = { type = "integer", default = 0, required = false } },
        },
      },
    },
  },
}
