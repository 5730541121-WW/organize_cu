class Department < ApplicationRecord
  has_many :personnels, class_name: 'Personnel', primary_key: 'id', foreign_key: 'workin_department_id'
end
