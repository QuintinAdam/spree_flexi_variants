module Spree
  ProductsController.class_eval do
    def customize
      # copied verbatim from 0.60 ProductsController#show, except that I changed id to product_id on following line
      # TODO: is there another way?  e.g. render action: "show", template: "customize" ?

      # new code in show action

      # @variants = @product.variants_including_master.active(current_currency).includes([:option_values, :images])
      # @product_properties = @product.product_properties.includes(:property)
      # @taxon = Spree::Taxon.find(params[:taxon_id]) if params[:taxon_id]

      # FIXTHIS
      # possible new if we can't get it to use the show
      @product = Product.friendly.find(params[:product_id])
      return unless @product

      @variants = Variant.active.includes([:option_values, :images]).where(product_id: @product.id)
      @product_properties = ProductProperty.includes(:property).where(product_id: @product.id)
      @selected_variant = @variants.detect { |v| v.available? }

      referer = request.env['HTTP_REFERER']

      # HTTP_REFERER_REGEXP (from spree) is unknown constant sometimes.  not sure why.
      # FIXTHIS I really don't like this
      if referer && referer.match(/^https?:\/\/[^\/]+\/t\/([a-z0-9\-\/]+)$/)
        @taxon = Taxon.find_by_permalink($1)
      end

      respond_with(@product)
    end
  end
end
