require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    self.model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] ||= (name.to_s.singularize + "_id").to_sym
    @class_name = options[:class_name] ||= (name.to_s.camelcase)
    @primary_key = options[:primary_key] ||= :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] ||= (self_class_name.underscore + "_id").to_sym
    @class_name = options[:class_name] ||= (name.to_s.camelcase.singularize)
    @primary_key = options[:primary_key] ||= :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)

    # foreign_key = options.foreign_key
    # primary_key = options.primary_key

    define_method(name) do
      options = self.class.assoc_options[name]
      foreign_key_val = self.attributes[options.foreign_key]

      options.model_class.where({options.primary_key => foreign_key_val}).first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)

    # foreign_key = options.foreign_key
    # primary_key = options.primary_key

    define_method(name) do
      options = self.class.assoc_options[name]
      primary_key_val = self.attributes[options.primary_key]

      options.model_class.where({options.foreign_key => primary_key_val})
    end
  end

  def assoc_options
    @associations ||= {}
    @associations
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
