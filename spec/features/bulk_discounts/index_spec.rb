require 'rails_helper'

RSpec.describe "Bulk Discounts Index Page" do
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

    visit merchant_bulk_discounts_path(@merchant1)
  end

  it "displays all the merchant's bulk discounts" do
    expect(page).to have_content("My Bulk Discounts")

    expect(page).to have_content(@discount_1.id)
    expect(page).to have_content(@discount_2.id)
    expect(page).to have_content(@discount_3.id)
  end
  
  it "displays the percentage discount and quantity threshold for each discount" do
    expect(page).to have_content("10% OFF")
    expect(page).to have_content("20% OFF")
    expect(page).to have_content("30% OFF")
    expect(page).to have_content("10 or more of an item")
    expect(page).to have_content("15 or more of an item")
    expect(page).to have_content("25 or more of an item")
  end

  it "each listed discount is a link to its show page" do
    click_link("Discount #{@discount_1.id}")
    expect(current_path).to eq(merchant_bulk_discount_path(@merchant1, @discount_1))
    
    visit merchant_bulk_discounts_path(@merchant1)
    click_link("Discount #{@discount_2.id}")
    expect(current_path).to eq(merchant_bulk_discount_path(@merchant1, @discount_2))
  end

  it "has a button to create a new discount" do
    expect(page).to have_button("Add New Discount")

    click_button "Add New Discount"
    expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant1))
  end

  describe "delete button" do
    it "has a button next to each bulk discount to delete it" do
      within "#discount-#{@discount_1.id}" do
      expect(page).to have_button("Delete")
      end

      within "#discount-#{@discount_2.id}" do
      expect(page).to have_button("Delete")
      end

      within "#discount-#{@discount_3.id}" do
      expect(page).to have_button("Delete")
      end
    end

    it "removes the discount from the index page" do
      expect(page).to have_content(@discount_3.id)
      within "#discount-#{@discount_3.id}" do
        click_button "Delete"
      end

      expect(page).to_not have_content(@discount_3.id)
    end

    it "redirects the user back to the bulk discounts index page and displays flash notice" do
      within "#discount-#{@discount_3.id}" do
        click_button "Delete"
      end

      expect(current_path).to eq(merchant_bulk_discounts_path(@merchant1))
      expect(page).to have_content("Your Discount Has Been Deleted")
    end
  end 

  describe "holidays section" do
    it "has a header titled Upcoming Holidays" do
      expect(page).to have_content("Upcoming Holidays")
    end

    it "displays the name and date of the next 3 US holidays" do
      expect(page).to have_content("Labour Day")
      expect(page).to have_content("Columbus Day")
      expect(page).to have_content("Veterans Day")
      save_and_open_page
      expect(page).to have_content("Veterans Day")
      expect(page).to have_content("Veterans Day")
      expect(page).to have_content("Veterans Day")
    end
  end

end