Factory.define :ad_hoc_variant_option_type do |f|
#  f.price_modifier_type "single"
  f.association :product
  f.association :option_type
end

Factory.define :ad_hoc_variant_option_value do |f|
  f.price_modifier 0
  f.association :option_value
  f.association :ad_hoc_variant_option_type
end
