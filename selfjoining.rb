# an assignment has many pre-class lessons in this instance

class Migration <ActiveRecord::Migration

  def change
    create_table :adults do |t|
      t.string :name_array
    end

    create_table :children do |t|
      t.string :name
      t.integer :father_id
      t.integer :mother_id
    end
  end
end

class Adult < ActiveRecord::Base
  has_many :children_as_father, class_name: "Child", foreign_key: "father_id"
  has_many :children_as_mother, class_name: "Child", foreign_key: "mother_id"

  def children
    children_as_father + children_as_mother
  end
end


class Child < ActiveRecord::Base
  belongs_to :father, class_name: "Adult", foreign_key: "father_id"
  belongs_to :mother, class_name: "Adult", foreign_key: "mother_id"

#bonus stuff
def children
  (children_as_father + children_as_mother)
end
end
