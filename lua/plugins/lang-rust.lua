-- Owns rust_analyzer entirely; it is excluded from lsp.lua's server list.
-- Wires codelldb into DAP itself, so dap.lua has no rust config.
-- Must not be lazy-loaded: it registers its own filetype handling.
return {
    "mrcjkb/rustaceanvim",
    version = "^7",
    lazy = false,
}
