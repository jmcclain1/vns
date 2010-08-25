class ActiveRecord::Migration
  def self.table_exists?(table_name)
    vals = select_all("DESC #{table_name}")
    return true
  rescue ActiveRecord::StatementInvalid
    return false
  end

  def self.column_exists?(table_name, column_name)
    val = select_one("select #{column_name} from #{table_name}")
    return true
  rescue ActiveRecord::StatementInvalid
    return false
  end
end