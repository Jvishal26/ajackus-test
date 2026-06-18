class AddColumnsToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :url, :string

    add_column :events, :state, :string
    add_column :events, :kind, :string

    add_column :events, :ends_at, :datetime

    add_column :events, :organizer_id, :integer
    add_column :events, :organizer_name, :string

    add_column :events, :minimum_price_cents, :integer
    add_column :events, :currency, :string

    add_column :events, :category, :string
    add_column :events, :subcategory, :string
    add_column :events, :event_type, :string

    add_column :events, :location_name, :string
    add_column :events, :address, :string
    add_column :events, :city, :string
    add_column :events, :postal_code, :string
    add_column :events, :country, :string

    add_column :events, :latitude, :decimal, precision: 10, scale: 6
    add_column :events, :longitude, :decimal, precision: 10, scale: 6
  end
end
