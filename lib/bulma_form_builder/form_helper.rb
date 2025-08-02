require 'bulma_form_builder/form_builder'

module BulmaFormBuilder
  module FormHelper
    # Ensure builder option is set and field_error_proc override is safe
    def bulma_form_with(model: false, scope: nil, url: nil, format: nil, **options, &block)
      options.reverse_merge!(builder: ::BulmaFormBuilder::FormBuilder)

      _with_bulma_form_field_error_proc do
        # form_with enforces keyword arguments
        form_with(model: model, scope: scope, url: url, format: format, **options, &block)
      end
    end

    # Wrap field_error_proc override with compatibility check
    def _with_bulma_form_field_error_proc
      if defined?(ActionView::Base.field_error_proc)
        original_proc = ActionView::Base.field_error_proc
        ActionView::Base.field_error_proc = proc { |html_tag, _instance_tag| html_tag }
        result = yield
        ActionView::Base.field_error_proc = original_proc
        result
      else
        # If field_error_proc is removed, skip override
        yield
      end
    end
  end
end
