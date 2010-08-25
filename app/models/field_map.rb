class FieldMap < Hash
  def initialize(*fields)
    fields.each do |field|
      add(field)
    end
  end

  def add(field)
    self[field.property_name] = field
  end

  def some(*field_names)
    field_names.collect do |field_name|
      self[field_name]
    end
  end
end
