Deface::Override.new(
  virtual_path: "spree/admin/orders/_line_items",
  name: "add_additional_line_item_fields_partial_to_admin_order_view",
  insert_bottom: ".line-item-name",
  text: "<%= render partial: 'spree/shared/additional_line_item_fields', locals: {item: item} %>"
)
