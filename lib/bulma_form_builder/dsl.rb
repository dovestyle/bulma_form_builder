require 'active_support/concern'

# BulmaFormBuilder::Dsl - Form Object DSL for metadata and accessors
module BulmaFormBuilder
  module Dsl
    extend ActiveSupport::Concern

    included do
      extend ClassMethods
    end

    module ClassMethods
      # Define the form structure for this form object
      def form_for(record_name, options = {}, &block)
        @form_definition ||= FormDefinition.new(record_name, options)
        @form_definition.instance_eval(&block) if block
      end

      # Access the stored form definition
      def form_definition
        @form_definition
      end
    end

    class FormDefinition
      attr_reader :record_name, :options, :fields, :groups, :form_actions

      def initialize(record_name, options = {})
        @record_name  = record_name
        @options      = options
        @fields       = []
        @groups       = []
        @form_actions = []
      end

      def field(name, type, **args)
        @fields << Field.new(name.to_sym, type, **args)
      end

      def group(title, &block)
        grp = Group.new(title)
        grp.instance_eval(&block) if block
        @groups << { title: title, fields: grp.fields }
      end

      def actions(&block)
        ctx = ActionContext.new
        ctx.instance_eval(&block) if block
        @form_actions = ctx.actions
      end
    end

    def field_method(type)
      type = type.to_s.downcase.to_sym
      case type
      when :color, :date, :datetime, :datetime_local, :email, :file, :hidden, :month, :number,
           :password, :phone, :range, :search, :telephone, :text, :time, :url, :week
        "#{type}_field".to_sym
      else
        # button, checkbox, radio_button, select, textarea
        type.to_sym
      end
    end

    def field_arguments(field)
      args = field.args || {}
      case field.type.to_s.downcase.to_sym
      when :checkbox, :check_box
        [ field.name, args[:options] || {}, args[:checked_value] || '1', args[:unchecked_value] || '0' ]
      when :radio_button
        [ field.name, args[:tag_value], args[:options] || {} ]
      when :collection_select
        [ field.name, args[:collection] || [], args[:value_method] || :id, args[:text_method] || :name, args[:options] || {}, args[:html_options] || {} ]
      when :grouped_collection_select
        [ field.name, args[:collection] || [], args[:group_method] || :group, args[:group_label_method] || :label, args[:option_key_method] || :id, args[:option_value_method] || :name, args[:text_method] || :name, args[:options] || {}, args[:html_options] || {} ]
      when :date_select, :datetime_select, :time_select, :weekday_select
        [ field.name, args[:options] || {}, args[:html_options] || {} ]
      when :time_zone_select
        [ field.name, args[:priority_zones] || nil, args[:options] || {}, args[:html_options] || {} ]
      when :select
        [ field.name, args[:choices] || [], args[:options] || {}, args[:html_options] || {} ]
      when :color, :date, :datetime, :datetime_local, :email, :file, :hidden, :month,
           :number, :password, :range, :rich_textarea, :rich_text_area, :search,
           :telephone, :phone, :textarea, :text_area, :text, :time, :url, :week
        [ field.name, args[:options] || {} ]
      end
    end

    def render(form)
      html = "".html_safe

      self.class.form_definition.fields.each do |field|
        args = field_arguments(field)
        html << form.send(field_method(field.type), *args)
      end

      self.class.form_definition.groups.each do |group|
        html << "<fieldset><legend>#{group.title}</legend>".html_safe
        group.fields.each do |field|
          args = field_arguments(field)
          html << form.send(field_method(field.type), *args)
        end
        html << "</fieldset>".html_safe
      end

      self.class.form_definition.form_actions.each do |action|
        if action[:type] == :submit
          html << form.submit(action[:label], **action[:attrs])
        elsif action[:type] == :cancel
          html << ActionController::Base.helpers.link_to(action[:label], "#", **action[:attrs])
        end
      end

      html
    end

    class Field
      attr_reader :name, :type, :args

      def initialize(name, type, **args)
        @name = name
        @type = type
        @args = args
      end
    end

    class Group
      attr_reader :title, :fields

      def initialize(title)
        @title = title
        @fields = []
      end

      def field(name, type = text, **options)
        @fields << Field.new(name.to_sym, type, **options)
      end
    end

    class ActionContext
      attr_reader :actions

      def initialize
        @actions = []
      end

      def submit(label, attrs = {})
        @actions << { type: :submit, label: label, attrs: attrs }
      end

      def cancel(label, attrs = {})
        @actions << { type: :cancel, label: label, attrs: attrs }
      end
    end
  end
end
