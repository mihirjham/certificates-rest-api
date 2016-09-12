class CreateCustomers < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :customers, id: :uuid do |t|
      t.string :name, null: false
      t.string :email_address, null: false

      t.timestamps
    end

    add_index :customers, :email_address, unique: true
  end
end
