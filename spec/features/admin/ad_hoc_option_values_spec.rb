require 'spec_helper'

describe 'Ad Hoc Option Values', js: true do
  describe 'remove links' do
    extend Spree::TestingSupport::AuthorizationHelpers::Request
    stub_authorization!

    before do
      @test_product = create(:product, name: 'Test Product', price: 12.99)
    end

    def setup_option_types_plus_ad_hoc_option_type
      color_option_type = create(:option_type, name: 'color', presentation: 'Color')
      red_value = create(:option_value, name: 'red', presentation: 'Red', option_type: color_option_type)
      green_value = create(:option_value, name: 'green', presentation: 'Green', option_type: color_option_type)
      blue_value = create(:option_value, name: 'blue', presentation: 'Blue', option_type: color_option_type)
      color_ad_hoc_option_type = create(:ad_hoc_option_type, option_type_id: color_option_type.id, product_id: @test_product.id)
      color_ad_hoc_option_type.ad_hoc_option_values.create!(option_value_id: red_value.id)
      color_ad_hoc_option_type.ad_hoc_option_values.create!(option_value_id: blue_value.id)
      color_ad_hoc_option_type.ad_hoc_option_values.create!(option_value_id: green_value.id)
    end

    def setup_option_types_plus_ad_hoc_option_type_number_two
      size_option_type = create(:option_type, name: 'size', presentation: 'Size')
      small_value = create(:option_value, name: 'small', presentation: 'Small', option_type: size_option_type)
      medium_value = create(:option_value, name: 'medium', presentation: 'Medium', option_type: size_option_type)
      large_value = create(:option_value, name: 'large', presentation: 'Large', option_type: size_option_type)
      size_ad_hoc_option_type = create(:ad_hoc_option_type, option_type_id: size_option_type.id, product_id: @test_product.id)
      size_ad_hoc_option_type.ad_hoc_option_values.create!(option_value_id: small_value.id)
      size_ad_hoc_option_type.ad_hoc_option_values.create!(option_value_id: medium_value.id)
      size_ad_hoc_option_type.ad_hoc_option_values.create!(option_value_id: large_value.id)
    end

    def go_to_product
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
    end

    def go_to_edit_ad_hoc_option_type
      click_on 'Ad Hoc Option Types'
      expect(page).to have_content('Add Option Types')
      find('.btn-primary .icon.icon-edit').click
      expect(page).to have_content('Editing Option Type')
    end

    def go_to_ad_hoc_variant_exclusions
      click_on 'Ad Hoc Variant Exclusions'
      expect(page).to have_content('Ad Hoc Variant Exclusions')
    end

    def go_to_edit_ad_hoc_variant_exclusions
      click_on 'Ad Hoc Variant Exclusions'
      expect(page).to have_content('Ad Hoc Variant Exclusions')
      find('.btn-primary .icon.icon-edit').click
      expect(page).to have_content('Editing Option Type')
    end

    it 'ad hoc option types add/removes the associated option value when clicked' do
      setup_option_types_plus_ad_hoc_option_type
      go_to_product
      go_to_edit_ad_hoc_option_type

      expect(all('#option_values tr').length).to eq(3)

      find('.icon.icon-delete').click
      expect(page).to_not have_content('No route matches')

      expect(all('#option_values tr').length).to eq(2)

      go_to_product

      go_to_edit_ad_hoc_option_type

      expect(all('#option_values tr').length).to eq(2)
      #add
      within('#available_option-values') do
        find('.icon.icon-add').click
      end
      expect(all('#option_values tr').length).to eq(3)
      #check the update
      check 'ad_hoc_option_type_is_required'
      within('#spree_ad_hoc_option_value_2') do
        fill_in 'ad_hoc_option_type_ad_hoc_option_values_attributes_0_price_modifier', with: '1'
        check 'ad_hoc_option_type_ad_hoc_option_values_attributes_0_selected'
      end
      click_on('Update')
      expect(page).to have_content('Ad hoc option type "color" has been successfully updated!')
      find('.btn-primary .icon.icon-edit').click
      expect find('#ad_hoc_option_type_is_required').should be_checked
      within('#spree_ad_hoc_option_value_2') do
        expect(page).to have_selector("input[value='1.0']")
        expect find('#ad_hoc_option_type_ad_hoc_option_values_attributes_0_selected').should be_checked
      end
      click_on('Cancel')
      expect(page).to have_content('Option Types')
      #test deleting a option type
      find('.icon.icon-delete').click
      expect(page).to have_content('Option Type Removed')
      expect(page).to have_content('No Ad hoc option type found, Add One!')
      #test adding an option type
      click_on('Add One')
      find('.icon.icon-add').click
      click_on('Update')
      expect(all('#ad_hoc_option_types tr').length).to eq(1)
    end

    it 'ad hoc variant exclusions add/removes the associated option value when clicked' do
      setup_option_types_plus_ad_hoc_option_type
      go_to_product
      go_to_ad_hoc_variant_exclusions
      expect(page).to have_content('You only need to configure exclusions when you have more than one ad hoc option type, Add One!')
      setup_option_types_plus_ad_hoc_option_type_number_two
      go_to_product
      go_to_ad_hoc_variant_exclusions
      expect(page).to have_content('No Ad hoc variant exclusion found, Add One!')
      click_on('Add One')
      select "red", from: 'ad_hoc_option_type_1'
      select "small", from: 'ad_hoc_option_type_2'
      click_on('Create')
      expect(all('#listing_ad_hoc_variant_exclusions tr').length).to eq(2)
      find('.icon.icon-delete').click
      expect(page).to have_content('No Ad hoc variant exclusion found, Add One!')
    end
  end
end

# save_and_open_page
# save_and_open_screenshot
