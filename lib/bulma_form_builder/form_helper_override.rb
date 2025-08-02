module BulmaFormBuilder
  module FormHelperOverride
    def form_with(model: false, scope: nil, url: nil, format: nil, **options, &block)
      # Use Builder error proc and builder by default
      options = options.reverse_merge(builder: BulmaFormBuilder::FormBuilder)
      BulmaFormBuilder::FormHelper.instance_method(:_with_bulma_form_field_error_proc).bind(self).call do
        super(model: model, scope: scope, url: url, format: format, **options, &block)
      end
    end
  end
end
