module Spree
  Order.class_eval do
    # FIXTHIS this is exactly the same it seems as Order Content add to line item.
    #this whole thing needs a refactor!
    def add_variant(variant, quantity = 1, options = {})
      # grab_line_item_by_variant???
      current_item = find_line_item_by_variant(variant, options)
      if current_item
        current_item.quantity += quantity
        current_item.save
      else
        current_item = LineItem.new(quantity: quantity, variant: variant, options: options)

        product_customizations_ids = (!!options[:product_customizations] ? options[:product_customizations].map{|ids| ids.first.to_i} : [])
        product_customizations_values = product_customizations_ids.map do |cid|
          ProductCustomization.find(product_customization_type_id: cid)
        end
        current_item.product_customizations = product_customizations_values
        product_customizations_values.each { |product_customization| product_customization.line_item = current_item }
        product_customizations_values.map(&:save) # it is now safe to save the customizations we built

        # find, and add the configurations, if any.  these have not been fetched from the db yet.              line_items.first.variant_id
        # we postponed it (performance reasons) until we actually knew we needed them
        ad_hoc_option_value_ids = (!!options[:ad_hoc_option_values] ? options[:ad_hoc_option_values] : [])
        product_option_values = ad_hoc_option_value_ids.map do |cid|
          AdHocOptionValue.find(cid)
        end
        current_item.ad_hoc_option_values = product_option_values

        offset_price = product_option_values.map(&:price_modifier).compact.sum + product_customizations_values.map {|product_customization| product_customization.price(variant)}.sum

        current_item.price = variant.price + offset_price

        self.line_items << current_item
      end
      current_item
    end

    # FIXTHIS could just take in options
    # never gets called?
    def contains?(variant, options = {})
      find_line_item_by_variant(variant, options).present?
    end

    # I think the new line_item_options_match will cover this
    # https://github.com/spree/spree/blob/625b42ecc2c3d5c6d0ec463a8f718ce16b80d89a/core/app/models/spree/order.rb#L265

    def find_line_item_by_variant(variant, options = {})
      ad_hoc_option_value_ids = ( !!options[:ad_hoc_option_values] ? options[:ad_hoc_option_values] : [] )
      product_customizations = ( !!options[:product_customizations] ? options[:product_customizations].map{|ids| ids.first.to_i} : [] )
      line_items.detect do |li|
        li.variant_id == variant.id &&
           matching_configurations(li.ad_hoc_option_values, ad_hoc_option_value_ids) &&
           matching_customizations(li.product_customizations, product_customizations)
      end
    end

    def merge!(order, user = nil)
      # this is bad, but better than before
      order.line_items.each do |other_order_line_item|
        next unless other_order_line_item.currency == order.currency

        # Compare the line items of the other order with mine.
        # Make sure you allow any extensions to chime in on whether or
        # not the extension-specific parts of the line item match
        current_line_item = self.line_items.detect do |my_li|
          my_li.variant == other_order_line_item.variant && self.line_item_comparison_hooks.all? do |hook|
            self.send(hook, my_li, other_order_line_item.serializable_hash)
          end
        end
        if current_line_item
          current_line_item.quantity += other_order_line_item.quantity
          current_line_item.save!
        else
          other_order_line_item.order_id = self.id
          other_order_line_item.save!
        end
      end
      order.line_items.each do |line_item|
        self.add_variant(line_item.variant, line_item.quantity, {
          ad_hoc_option_values: line_item.ad_hoc_option_value_ids,
          product_customizations: line_item.product_customizations
        })
      end

      self.associate_user!(user) if !self.user && !user.blank?

      updater.update_item_count
      updater.update_item_total
      updater.persist_totals

      # So that the destroy doesn't take out line items which may have been re-assigned
      order.line_items.reload
      order.destroy
    end

    private

    # produces a list of [customizable_product_option.id,value] pairs for subsequent comparison
    # def customization_pairs(product_customizations)
    #   pairs= product_customizations.map(&:customized_product_options).flatten.map do |m|
    #     [m.customizable_product_option.id, m.value.present? ? m.value : m.customization_image.to_s ]
    #   end

    #   Set.new pairs
    # end

    def matching_configurations(existing_povs, new_povs)
      # if there aren't any povs, there's a 'match'
      return true if existing_povs.empty? && new_povs.empty?

      existing_povs.map(&:id).sort == new_povs.map(&:to_i).sort
    end

    def matching_customizations(existing_customizations, new_customizations)

      # if there aren't any customizations, there's a 'match'
      return true if existing_customizations.empty? && new_customizations.empty?

      # exact match of all customization types?
      return false unless existing_customizations.map(&:product_customization_type_id).sort == new_customizations.map(&:product_customization_type_id).sort

      # get a list of [customizable_product_option.id,value] pairs
      existing_vals = customization_pairs existing_customizations
      new_vals      = customization_pairs new_customizations

      # do a set-compare here
      existing_vals == new_vals
    end
  end
end
