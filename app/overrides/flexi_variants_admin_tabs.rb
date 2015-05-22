# admin_tabs data-hook missing changing to look at main_menu bar
Deface::Override.new(
  virtual_path: "spree/admin/shared/sub_menu/_product",
  name: "flexi_variants_admin_tabs",
  insert_bottom: "#sidebar-product",
  original: '1950c492f6ee166b7d4eedb6b9076ab3e986f110',
  text: '<%= tab :customization_types, url: spree.admin_product_customization_types_path %>'
)
