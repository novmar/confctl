require 'md2man/rakefile'
require 'md2man/roff/engine'
require 'md2man/html/engine'

# Override markdown engine to add extra parameter
[Md2Man::Roff, Md2Man::HTML].each do |mod|
  mod.send(:remove_const, :ENGINE)
  mod.send(:const_set, :ENGINE, Redcarpet::Markdown.new(mod.const_get(:Engine),
    tables: true,
    autolink: true,
    superscript: true,
    strikethrough: true,
    no_intra_emphasis: false,
    fenced_code_blocks: true,

    # This option is needed for command options to be rendered property
    disable_indented_code_blocks: true,
  ))
end
