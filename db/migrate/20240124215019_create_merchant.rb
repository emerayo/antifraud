# frozen_string_literal: true

class CreateMerchant < ActiveRecord::Migration[7.0]
  def change
    create_table :merchants do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
