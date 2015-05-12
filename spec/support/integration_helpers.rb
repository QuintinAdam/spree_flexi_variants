module IntegrationHelpers

  def login_user(user = nil, options = {})
    options[:password] ||= 'secret'
    user ||= create(:user)

    visit spree.root_path
    click_link 'Login'
    fill_in 'spree_user[email]', with: user.email
    fill_in 'spree_user[password]', with: options[:password]
    click_button 'Login'
    page.should_not have_content 'Login'
  end

  def go_to_product_page
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
end
