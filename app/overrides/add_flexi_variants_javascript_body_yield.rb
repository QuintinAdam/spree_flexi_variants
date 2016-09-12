Deface::Override.new(
  virtual_path: "spree/layouts/spree_application",
  name: "add_flexi_variants_javascript_body_yield",
  insert_bottom: "body",
  partial: "spree/shared/flexi_variants_body_js"
)
