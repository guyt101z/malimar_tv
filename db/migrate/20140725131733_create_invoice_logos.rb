class CreateInvoiceLogos < ActiveRecord::Migration
  def change
    create_table :invoice_logos do |t|
      t.string :image
      t.timestamps
    end
  end
end
