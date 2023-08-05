require 'rails_helper'

RSpec.describe "Bulk Discounts New Page" do
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

    visit new_merchant_bulk_discount_path(@merchant1)
  end

  it "has a form to add a new bulk discount" do
    expect(page).to have_content("Add New Discount")
    expect(page).to have_field("Percentage discount")
    expect(page).to have_field("Quantity threshold")
    expect(page).to have_button("Submit")
  end
  
  describe "successful form submission" do
    it "redirects to the bulk discount index and displays a flash message" do
      fill_in "Percentage discount", with: "35"
      fill_in "Quantity threshold", with: "30"
      click_button "Submit"
      expect(current_path).to eq(merchant_bulk_discounts_path(@merchant1))
      expect(page).to have_content("New Discount Successfully Created!")
    end
    
    it "displays the newly created discount" do
      visit merchant_bulk_discounts_path(@merchant1)
      expect(page).to_not have_content("35% OFF")
      
      visit new_merchant_bulk_discount_path(@merchant1)
      fill_in "Percentage discount", with: "35"
      fill_in "Quantity threshold", with: "30"
      click_button "Submit"
      
      expect(page).to have_content("35% OFF")
      expect(page).to have_content("30 or more of an item")
    end
  end
  
  describe "unsuccessful form submission" do
    it "renders the creation form again" do
      click_button "Submit"

      expect(page).to have_content("Add New Discount")
      expect(page).to have_field("Percentage discount")
      expect(page).to have_field("Quantity threshold")
      expect(page).to have_button("Submit")
    end
    
    it "displays a flash message to notify user" do
      click_button "Submit"

      expect(page).to have_content("Please complete all fields to continue.")
    end
  end

  describe "submission of unaccepted characters" do
    xit "automatically corrects commonly predicted user entries" do
      fill_in "Percentage discount", with: "35%"
      fill_in "Quantity threshold", with: "30"
      click_button "Submit"

      # expect
    end
  end
end
# ADD EDGE CASES HERE FOR FILLING IN FORM WITH WRONG DATA TYPES