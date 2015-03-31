module ProductCustomizations
  # given params[:customizations], return a non-persisted array of ProductCustomization objects
  def product_customizations
    customizations = []
    # do we have any customizations?
    params[:product_customizations].each do |customization_type_id, customization_pair_value|  # customization_type_id =>
      # {customized_product_option_id => <user input>,  etc.}
      next if customization_pair_value.empty? || customization_pair_value.values.all? {|value| value.empty?}
      # create a product_customization based on customization_type_id
      product_customization = Spree::ProductCustomization.new(product_customization_type_id: customization_type_id)
      customization_pair_value.each_pair do |customized_option_id, user_input|
        # create a customized_product_option based on customized_option_id
        customized_product_option = Spree::CustomizedProductOption.new
        # attach to its 'type'
        customized_product_option.customizable_product_option_id = customized_option_id
        if user_input.is_a? String
          customized_product_option.value = user_input
        else
          customized_product_option.value = "" # TODO revisit. What should be here
          customized_product_option.customization_image = user_input["customization_image"]
        end
        # attach to its customization
        product_customization.customized_product_options << customized_product_option
      end
      customizations << product_customization
    end if params[:product_customizations]
    customizations
  end
end
