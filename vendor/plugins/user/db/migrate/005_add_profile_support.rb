class AddProfileSupport < ActiveRecord::Migration
  def self.up
    unless table_exists?("profiles")
      create_table "profiles", :force => true do |t|
        t.column "user_id", :integer
        t.column "created_at", :datetime
        t.column "updated_at", :datetime
      end
    end

    unless table_exists?("profile_answers")
      create_table "profile_answers", :force => true do |t|
        t.column "profile_id",  :integer
        t.column "question_id", :integer
        t.column "value",       :string
      end
    end

    unless table_exists?("profile_question_categories")
      create_table "profile_question_categories", :force => true do |t|
        t.column "name",         :string,  :limit => 64
        t.column "display_name", :string
        t.column "sort_order",   :integer
      end
    end

    unless table_exists?("profile_questions")
      create_table "profile_questions", :force => true do |t|
        t.column "type",         :string
        t.column "name",         :string,  :limit => 64, :default => "", :null => false
        t.column "display_name", :string
        t.column "category_id",  :integer
        t.column "sort_order",   :integer
      end
    end
  end

  def self.down
    drop_table "profile_questions"
    drop_table "profile_question_categories"
    drop_table "profile_answers"
    drop_table "profiles"
  end

  
end