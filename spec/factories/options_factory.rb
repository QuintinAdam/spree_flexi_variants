# I want to have unique name/presentations, so 'override' what spree_core gives us
Factory.define :option_value2, :class => OptionValue do |f|
  f.name { Faker::Lorem.words }
  f.presentation { Faker::Lorem.words }
  f.association :option_type, :factory => :option_type2
end

Factory.define :option_type2, :class => OptionType do |f|
  f.name { Faker::Lorem.words }
  f.presentation { Faker::Lorem.words }
end
