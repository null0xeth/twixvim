--vim.loader.enable()
require("framework.controller.enginecontroller"):new():initialize_nvim()
print(vim.bo.filetype)
--require("util.statuscol2")
