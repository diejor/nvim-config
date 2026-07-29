(call_expression
  function: (identifier) @_name
  (#eq? @_name "sql")
  arguments: (template_string) @sql
  ; The #offset! predicate removes the tag and the backticks from the highlighted area
  (#offset! @sql 0 0 0 0)
)
