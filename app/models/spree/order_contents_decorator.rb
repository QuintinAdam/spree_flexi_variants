module Spree
  OrderContents.class_eval do

    private

    def add_to_line_item(variant, quantity, options = {})
      line_item = grab_line_item_by_variant(variant, false, options)

     if line_item
       line_item.quantity += quantity.to_i
       line_item.currency = currency unless currency.nil?
      else
        options[:currency] = order.currency
        # might not need to pass in options #NEEDTOCHECK
        line_item = order.line_items.new(quantity: quantity, variant: variant, options: options)
        product_customizations = options[:product_customizations]
        line_item.product_customizations = product_customizations

        product_customizations.each { |product_customization| product_customization.line_item = line_item }

        product_customizations.map(&:save) # it is now safe to save the customizations we built

        # find, and add the configurations, if any.  these have not been fetched from the db yet.              line_items.first.variant_id
        # we postponed it (performance reasons) until we actually know we needed them
        product_option_values = []
        ad_hoc_option_value = params[:ad_hoc_option_values]
        ad_hoc_option_value.each do |cid|
          product_option_values << AdHocOptionValue.find(cid)
        end
        line_item.ad_hoc_option_values = product_option_values

        offset_price = product_option_values.map(&:price_modifier).compact.sum + product_customizations.map {|product_customization| product_customization.price(variant)}.sum

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
