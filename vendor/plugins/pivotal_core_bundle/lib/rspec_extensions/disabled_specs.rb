module DisabledSpecs
  def xspecify(name, &specification)
    warn "Specification #{name.inspect} is disabled"
  end

  def xit(name, &specification)
    warn "Example #{name.inspect} is disabled"
  end
end
