module Spree
  OrdersController.class_eval do
    include ProductCustomizations
    include AdHocUtils

    before_action :set_option_params_values, only: [:populate]

    private

    def set_option_params_values
      params[:options] ||= {}
      params[:options][:ad_hoc_option_values] = ad_hoc_option_value_ids
      params[:options][:product_customizations] = product_customizations
      params[:options][:customization_price] = params[:customization_price] if params[:customization_price]
    end
  end
end
