class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.references :brand

      t.string :title
      t.text :description
      t.float :price

      t.timestamps null: false
    end
  end
end
