class Advisor < ApplicationRecord
	belongs_to :student
	belongs_to :personnel
end
