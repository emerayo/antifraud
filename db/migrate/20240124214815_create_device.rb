# frozen_string_literal: true

class CreateDevice < ActiveRecord::Migration[7.0]
  def change
    create_table :devices do |t|
      t.string :manufacturer
      t.string :model

      t.timestamps
    end
  end
end
