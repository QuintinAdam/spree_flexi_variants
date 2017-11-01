# SpreeFlexiVariants

For Spree 3.2.0+

This is a [spree](http://spreecommerce.com) extension that solves two use cases related to variants.  I call them **Ad Hoc Options** and **Product Customizations**.

### Ad Hoc Options

Use these when have numerous (possibly price-altering) product options and you don't want to create variants for each combination.

You can also restrict certain combinations of options from coexisting.  These are called **Ad Hoc Exclusions**.

### Product Customizations

Use these when you want the ability to provide a highly customized product e.g. "Cut to length 5.82cm", "Engrave 'thanks for the memories'", "Upload my image".  Full control over pricing is provided by the Spree calculator mechanism.

## Version Notes

The branch spree-3-1-experimental is an untested by myself version for spree 3.1.0. Please let me know (send a pull request) if it is missing anything.

The branch spree-3-0-stable is an somewhat stable version for spree 3.0.0 with updated styles to match.

Working with a older spree? Check out the original gem or one of the many forks. https://github.com/jsqu99/spree_flexi_variants

## Installation

    # see the notes in Versionfile if you are using an older version of spree
    gem 'spree_flexi_variants', github: 'medaved/spree_flexi_variants', branch: 'multi_currency'

    bundle install

    bundle exec rails g spree_flexi_variants:install

## Examples

Build a 'Cake' product using **Ad Hoc Options** and **Product Customizations**

![Cake](https://raw.github.com/QuintinAdam/spree_flexi_variants/master/doc/custom_cake.png)

Build a 'Necklace'  product using **Ad Hoc Options** and **Product Customizations**

![Necklace](https://raw.github.com/jsqu99/spree_flexi_variants/master/doc/necklace_screenshot.png)

Build a 'Pizza' product using **Ad Hoc Options**. Note that the 'multi' option checkboxes come from a partial named after the option name (see app/views/products/ad_hoc_options/_toppings.html.erb)

![Picture Frame](https://raw.github.com/jsqu99/spree_flexi_variants/master/doc/pizza_screenshot.png)

See the [wiki](https://github.com/jsqu99/spree_flexi_variants/wiki) for more detail.
