require 'spec_helper'

describe 'Ad Hoc Option Values', js: true do
  describe 'remove links' do
    extend Spree::TestingSupport::AuthorizationHelpers::Request
    stub_authorization!

    before do
      test_product = create(:product, name: 'Test Product', price: 12.99)
      color_option_type = create(:option_type, name: 'color', presentation: 'Color')
      red_value = create(:option_value, name: 'red', presentation: 'Red', option_type: color_option_type)
      green_value = create(:option_value, name: 'green', presentation: 'Green', option_type: color_option_type)
      blue_value = create(:option_value, name: 'blue', presentation: 'Blue', option_type: color_option_type)
      color_ad_hoc_option_type = create(:ad_hoc_option_type, option_type_id: color_option_type.id, product_id: test_product.id)
      color_ad_hoc_option_type.ad_hoc_option_values.create!(option_value_id: red_value.id)
      color_ad_hoc_option_type.ad_hoc_option_values.create!(option_value_id: blue_value.id)
      color_ad_hoc_option_type.ad_hoc_option_values.create!(option_value_id: green_value.id)
    end

    it 'removes the associated option value when clicked' do
      visit '/admin'
      click_on 'Products'
      expect(find('#sidebar-product').visible?).to eq(true)
      within("#sidebar-product") do
        click_on("Products")
      end
      within('.content-header') do
        expect(page).to have_content('Products')
      end
      click_on 'Test Product'
      within('.content-header') do
        expect(page).to have_content('Products / Test Product')
      end
      click_on 'Ad Hoc Option Types'
      find('.icon.icon-edit').click
      expect(page).to have_content('Editing Option Type')
      expect(all('#option_values tr').length).to eq(3)

      find('.icon.icon-delete').click
      expect(page).to_not have_content('No route matches')
      expect(all('#option_values tr').length).to eq(2)
      visit '/admin'
      click_on 'Products'
      within("#sidebar-product") do
        click_on("Products")
      end
      click_on 'Test Product'
      click_on 'Ad Hoc Option Types'

      find('.icon.icon-edit').click
      expect(all('#option_values tr').length).to eq(2)
    end
  end
end
