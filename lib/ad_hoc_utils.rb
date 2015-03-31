module AdHocUtils

  def ad_hoc_option_value_ids # (variant_id)
    ids = []
    params[:ad_hoc_option_values].each do |ignore, product_option_value_id|
      # pov=ProductOptionValue.find( product_option_value_id)   # we don't actually need to load these from the DB just yet.  We might already have them attached to the line item
      # when it's a multi-select
      if  product_option_value_id.is_a?(Array)
         product_option_value_id.each do |p|
          ids << p unless p.empty?
        end
      else
        ids <<  product_option_value_id unless  product_option_value_id.empty?
      end
    end if params[:ad_hoc_option_values]
    ids
  end
end
