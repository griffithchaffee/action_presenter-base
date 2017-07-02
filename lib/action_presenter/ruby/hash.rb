class Hash
  # dig value from nested hash using html name
  def dig_html(name)
    # convert "key1[key2][key3][]" => ["key1", "key2", "key3"]
    parts = name.to_s.split(/\]\[|\[\]?|\]/)
    parts.present? ? dig(*parts) : nil
  end
end
