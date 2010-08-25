class GenericStockPhoto < Photo
  has_versions  :full_size => Asset::Command::Photo::ScaledDownToFit.new(700,500)
end