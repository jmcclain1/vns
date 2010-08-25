class NilUser < User
  def self.instance
    @@instance ||= NilUser.new
  end
  
  def nil?
    true
  end
end