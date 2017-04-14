class CreateAdvisors < ActiveRecord::Migration[5.0]
  def change
    create_table :advisors do |t|
      
      t.references :student, null: false
      t.references :personnel, null: false

      t.timestamps
    end
  end
end
