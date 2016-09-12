class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates, id: :uuid do |t|
      t.uuid :customer_id, null: false
      t.boolean :active, default: true, null: false
      t.text :private_key, null: false
      t.text :body, null: false

      t.timestamps
    end

    add_index :certificates, :customer_id
    add_index :certificates, :private_key, unique: true
  end
end
