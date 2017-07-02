class String
  # convert "name1[name2]" to "name1_name2"
  def slugify_html
    scan(/[A-Za-z0-9]+/).join("_").underscore
  end
end
