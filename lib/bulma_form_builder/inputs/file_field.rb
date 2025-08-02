module BulmaFormBuilder
  module Inputs
    module FileField
      extend ActiveSupport::Concern

      include Base

      included do
        def file_field_with_bulma(method, options = {})
          form_field_builder(method, options) do
            classes = [options[:class], 'file-input']
            classes << 'is-danger' if error?(method)
            options[:class] = classes.compact.join(' ')

            content_tag(:div, class: 'file has-name') do
              content_tag(:label, class: 'file-label') do
                html = file_field_without_bulma(method, options)
                html.concat(
                  content_tag(:span, class: 'file-cta') do
                    content_tag(:span, class: 'file-icon') do
                      content_tag(:i, '', class: 'mdi mdi-upload')
                    end
                    content_tag(:span, options[:label] || I18n.t('bulma_form_builder.file_field.choose_file', default: 'Choose a file...'), class: 'file-label')
                  end
                )
                html.concat(content_tag(:span, method.to_s, class: 'file-name'))
                html
              end
            end
          end
        end

        bulma_alias(:file_field)
      end
    end
  end
end
