# admin_tabs data-hook missing changing to look at main_menu bar
Deface::Override.new(
  virtual_path: "/spree/admin/shared/_main_menu",
  name: "flexi_variants_admin_tabs",
  insert_after: "ul") do
  '<% if can? :admin, Spree::Product %>
    <ul class="nav nav-sidebar">
      <%= tab :product_customization_types, url: spree.admin_product_customization_types_path, icon: "option-horizontal" %>
    </ul>
  <% end %>'
end
