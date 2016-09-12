class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.integer :customer_id, null: false
      t.boolean :active, default: true, null: false
      t.string :private_key, null: false
      t.text :body, null: false
    end

    add_index :certificates, :customer_id
    add_index :certificates, :private_key, unique: true
  end
end
