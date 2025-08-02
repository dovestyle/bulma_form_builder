module BulmaFormBuilder
  module Inputs
    module Base
      extend ActiveSupport::Concern

      ELEMENTS_WITH_INPUT_CLASS = %i[email_field url_field number_field password_field text_field].freeze

      class_methods do
        def bulma_field(field_name)
          if instance_methods.include?(field_name)
            define_method "#{field_name}_with_bulma" do |name, options = {}|
              form_field_builder(name, options) do
                classes = [options[:class]]
                classes <<= 'input' if ELEMENTS_WITH_INPUT_CLASS.include?(field_name)
                classes <<= 'is-danger' if error?(name)
                options[:class] = classes.compact.join(' ')

                send("#{field_name}_without_bulma".to_sym, name, options)
              end
            end

            bulma_alias(field_name)
          else
            # If the helper is missing, skip monkey-patching
            # Raise an error??
          end
        end

        def bulma_alias(field_name)
          # Only alias if the method exists
          if instance_methods.include?(field_name)
            alias_method "#{field_name}_without_bulma".to_sym, field_name
            alias_method field_name, "#{field_name}_with_bulma".to_sym
          end
        end
      end
    end
  end
end
