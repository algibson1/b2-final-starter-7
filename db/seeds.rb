# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Transaction.destroy_all
InvoiceItem.destroy_all
BulkDiscount.destroy_all
Invoice.destroy_all
Item.destroy_all
Merchant.destroy_all
Customer.destroy_all

Rake::Task["csv_load:all"].invoke

merchant_ids = Merchant.all.map {|merchant| merchant.id}
300.times do |i|
  FactoryBot.create(:bulk_discount, merchant_id: merchant_ids.sample)
end