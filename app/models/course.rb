class Course < ApplicationRecord
  has_many :sections
  has_many :personnels, :through => :sections

  belongs_to :code
end
