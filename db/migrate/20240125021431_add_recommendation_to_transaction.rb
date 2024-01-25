# frozen_string_literal: true

class AddRecommendationToTransaction < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :recommendation, :string
  end
end
