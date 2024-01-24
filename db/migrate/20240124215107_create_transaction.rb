# frozen_string_literal: true

class CreateTransaction < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.references :device
      t.references :merchant
      t.references :user

      t.string :card_number
      t.datetime :date
      t.float :amount

      t.timestamps
    end
  end
end
