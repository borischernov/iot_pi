helpers do
  def check_box(object, method, checked = false, options = {})
    options.merge!(
      type: :checkbox, 
      checked: checked ? :checked : nil,
      name: "#{object}[#{method}]",
      id: "#{object}_#{method}",
      value: 1
    )
    single_tag(:input, options)
  end

  def select(obj, field, values, options={})
    sv = options.delete(:value)
    value = param_or_default(obj, field, sv).to_s
    content = Array(values).map do |val|
      id, text = id_and_text_from_value(val)
      tag_options = { :value => id }
      tag_options[:selected] = 'selected' if id.to_s == value
      tag(:option, text, tag_options)
    end.join("")
    tag :select, content, options.merge(:id => css_id(obj, field), :name => "#{obj}[#{field}]")
  end

end