require 'bulma_form_builder/railtie'
require 'bulma_form_builder/dsl'
require 'bulma_form_builder/form_helper_override'

module BulmaFormBuilder
  def self.override_default
    # Override the default form builder globally
    ActionView::Base.default_form_builder = BulmaFormBuilder::FormBuilder

    # Override form_with to use BulmaFormBuilder by default
    ActionView::Base.prepend(BulmaFormBuilder::FormHelperOverride)
  end
end
