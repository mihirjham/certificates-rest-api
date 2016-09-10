class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.string :email_address, null: false

      t.timestamps
    end

    add_index :customers, :email_address, unique: true
  end
end
