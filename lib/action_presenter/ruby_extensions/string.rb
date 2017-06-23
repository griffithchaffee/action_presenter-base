class String
  # convert "name1[name2]" to "name1_name2"
  def html_slugify
    scan(/[A-Za-z0-9]+/).join("_").underscore
  end

  def dig_html(name)
    # convert "key1[key2][key3][]" to ["key1", "key2", "key3"]
    parts = name.to_s.split(/\]\[|\[\]?|\]/)
    dig(*parts) if parts.present?
  end
end
