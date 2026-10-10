class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.bigint :price_cents
      t.string :status, null: false, default: "draft"
      t.timestamps
    end
    add_check_constraint :products, "status IN ('draft', 'published')", name: "products_valid_status"
    add_check_constraint :products,
      "status <> 'published' OR (name IS NOT NULL AND length(trim(name)) > 0 AND price_cents IS NOT NULL AND price_cents > 0)",
      name: "published_products_have_name_and_price"
  end
end
