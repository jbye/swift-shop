class AddImageUrlToProduct < ActiveRecord::Migration
  def change
    add_column :products, :image_url, :text
    add_column :brands, :image_url, :text
  end
end
