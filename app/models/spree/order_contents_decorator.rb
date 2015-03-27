module Spree
  OrderContents.class_eval do

    private
    #this whole thing needs a refactor!

    def add_to_line_item(variant, quantity, options = {})
      line_item = grab_line_item_by_variant(variant, false, options)
      if line_item
        line_item.quantity += quantity.to_i
        line_item.currency = currency unless currency.nil?
      else
        opts = { currency: order.currency }.merge ActionController::Parameters.new(options).permit(PermittedAttributes.line_item_attributes)
        line_item = order.line_items.new(quantity: quantity, variant: variant, options: opts)

        product_customizations_ids = ( !!options[:product_customizations] ? options[:product_customizations].map{|ids| ids.first.to_i} : [] )
        product_customizations_values = product_customizations_ids.map do |cid|
          ProductCustomization.find_by_product_customization_type_id(cid)
        end
        line_item.product_customizations = product_customizations_values
        product_customizations_values.each { |product_customization| product_customization.line_item = line_item }
        product_customizations_values.map(&:save) # it is now safe to save the customizations we built

        # find, and add the configurations, if any.  these have not been fetched from the db yet.              line_items.first.variant_id
        # we postponed it (performance reasons) until we actually know we needed them
        ad_hoc_option_value_ids = ( !!options[:ad_hoc_option_values] ? options[:ad_hoc_option_values].map{|ids| ids.last}  : [] )
        product_option_values = ad_hoc_option_value_ids.map do |cid|
          AdHocOptionValue.find(cid) if cid.present?
        end.compact
        line_item.ad_hoc_option_values = product_option_values

        offset_price = product_option_values.map(&:price_modifier).compact.sum + product_customizations_values.map {|product_customization| product_customization.price(variant)}.sum

        if currency
          line_item.currency = currency unless currency.nil?
          line_item.price    = variant.price_in(currency).amount + offset_price
        else
          line_item.price    = variant.price + offset_price
        end
      end
      line_item.target_shipment = options[:shipment] if options.has_key? :shipment
      line_item.save!
      line_item
    end
  end
end
