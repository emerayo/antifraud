# frozen_string_literal: true

require 'csv'

# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the bin/rails db:seed command
# (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

puts 'Starting seed'
puts '============='

connection = ActiveRecord::Base.connection

csv = CSV.open('sample_data.txt', headers: true)

puts 'Start User import'
user_ids = csv.filter_map { |row| row['user_id'] }.uniq
user_ids.map! { |id| "(#{id}, '2024-01-25 18:03:28.604436', '2024-01-25 18:03:28.604436')" }
sql_insert = "INSERT INTO users (id, created_at, updated_at) VALUES #{user_ids.join(',')}"
connection.execute(sql_insert)
puts "Imported #{user_ids.size} Devices"
puts '============='

puts 'Start Merchant import'
csv = CSV.open('sample_data.txt', headers: true)
merchant_ids = csv.filter_map { |row| row['merchant_id'] }.uniq
merchant_ids.map! { |id| "(#{id}, '2024-01-25 18:03:28.604436', '2024-01-25 18:03:28.604436')" }
sql_insert = "INSERT INTO merchants (id, created_at, updated_at) VALUES #{merchant_ids.join(',')}"
connection.execute(sql_insert)
puts "Imported #{merchant_ids.size} Devices"
puts '============='

puts 'Start Device import'
csv = CSV.open('sample_data.txt', headers: true)
device_ids = csv.filter_map { |row| row['device_id'] }.uniq
device_ids.map! { |id| "(#{id}, '2024-01-25 18:03:28.604436', '2024-01-25 18:03:28.604436')" }
sql_insert = "INSERT INTO devices (id, created_at, updated_at) VALUES #{device_ids.join(',')}"
connection.execute(sql_insert)
puts "Imported #{device_ids.size} Devices"
