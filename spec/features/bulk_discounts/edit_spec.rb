require 'rails_helper'

RSpec.describe "Bulk Discounts Edit Page" do
  before do
    @merchant1 = Merchant.create!(name: "Hair Care")

    @customer_1 = Customer.create!(first_name: "Joey", last_name: "Smith")
    @customer_2 = Customer.create!(first_name: "Cecilia", last_name: "Jones")
    @customer_3 = Customer.create!(first_name: "Mariah", last_name: "Carrey")
    @customer_4 = Customer.create!(first_name: "Leigh Ann", last_name: "Bron")
    @customer_5 = Customer.create!(first_name: "Sylvester", last_name: "Nader")
    @customer_6 = Customer.create!(first_name: "Herber", last_name: "Kuhn")

    @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2)
    @invoice_2 = Invoice.create!(customer_id: @customer_1.id, status: 2)
    @invoice_3 = Invoice.create!(customer_id: @customer_2.id, status: 2)
    @invoice_4 = Invoice.create!(customer_id: @customer_3.id, status: 2)
    @invoice_5 = Invoice.create!(customer_id: @customer_4.id, status: 2)
    @invoice_6 = Invoice.create!(customer_id: @customer_5.id, status: 2)
    @invoice_7 = Invoice.create!(customer_id: @customer_6.id, status: 1)

    @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id)
    @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: @merchant1.id)
    @item_3 = Item.create!(name: "Brush", description: "This takes out tangles", unit_price: 5, merchant_id: @merchant1.id)
    @item_4 = Item.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 1, merchant_id: @merchant1.id)

    @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 0)
    @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 1, unit_price: 8, status: 0)
    @ii_3 = InvoiceItem.create!(invoice_id: @invoice_2.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 2)
    @ii_4 = InvoiceItem.create!(invoice_id: @invoice_3.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    @ii_5 = InvoiceItem.create!(invoice_id: @invoice_4.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    @ii_6 = InvoiceItem.create!(invoice_id: @invoice_5.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    @ii_7 = InvoiceItem.create!(invoice_id: @invoice_6.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)

    @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)
    @transaction2 = Transaction.create!(credit_card_number: 230948, result: 1, invoice_id: @invoice_3.id)
    @transaction3 = Transaction.create!(credit_card_number: 234092, result: 1, invoice_id: @invoice_4.id)
    @transaction4 = Transaction.create!(credit_card_number: 230429, result: 1, invoice_id: @invoice_5.id)
    @transaction5 = Transaction.create!(credit_card_number: 102938, result: 1, invoice_id: @invoice_6.id)
    @transaction6 = Transaction.create!(credit_card_number: 879799, result: 1, invoice_id: @invoice_7.id)
    @transaction7 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_2.id)

    @discount_1 = @merchant1.bulk_discounts.create!(percentage_discount: 10, quantity_threshold: 10)
    @discount_2 = @merchant1.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 15)
    @discount_3 = @merchant1.bulk_discounts.create!(percentage_discount: 30, quantity_threshold: 25)

    visit edit_merchant_bulk_discount_path(@merchant1, @discount_1)
  end

  describe "form" do
    it "has auto-populated fields to edit bulk discount attributes" do
      expect(page).to have_content("Edit Discount")
      expect(page).to have_field("Percentage discount", with: @discount_1.percentage_discount)
      expect(page).to have_field("Quantity threshold", with: @discount_1.quantity_threshold)
      expect(page).to have_button("Update")
    end
  end

  describe "successful form submission" do
    it "redirects to the bulk discount show page and shows a flash message" do
      fill_in "Percentage discount", with: "5"
      fill_in "Quantity threshold", with: "12"
      click_button "Update"

      @discount_1.reload

      expect(current_path).to eq(merchant_bulk_discount_path(@merchant1, @discount_1))
      expect(page).to have_content("Discount #{@discount_1.id} has been successfully updated!")
    end

    it "displays the newly updated bulk discount information" do
      expect(@discount_1.percentage_discount).to eq(10)
      expect(@discount_1.quantity_threshold).to eq(10)

      fill_in "Percentage discount", with: "5"
      fill_in "Quantity threshold", with: "12"
      click_button "Update"

      @discount_1.reload

      expect(@discount_1.percentage_discount).to eq(5)
      expect(@discount_1.quantity_threshold).to eq(12)
      expect(page).to have_content("Percentage Discount: 5% OFF")
      expect(page).to have_content("Quantity Threshold: 12 or more items")
    end
  end

  describe "unsuccessful form submission" do
    it "loads the edit page again" do
      fill_in "Percentage discount", with: ""
      fill_in "Quantity threshold", with: ""
      click_button "Update"

      expect(page).to have_content("Edit Discount")
      expect(page).to have_field("Percentage discount")
      expect(page).to have_field("Quantity threshold")
    end

    it "displays a message to notify user of failed edit" do
      fill_in "Percentage discount", with: ""
      fill_in "Quantity threshold", with: ""
      click_button "Update"

      expect(page).to have_content("Enter valid updates to continue.")
    end
  end
end