-- Prose grammar checking. Narrowed from ltex's broad default filetype list.
return {
    filetypes = { "tex", "bib", "markdown" },
    settings = {
        ltex = {
            language = "en-US",
        },
    },
}
