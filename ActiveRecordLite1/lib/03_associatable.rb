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
    @class_name = options[:class_name] ||= (name.camelcase.singularize)
    @primary_key = options[:primary_key] ||= :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    foreign_key = options.send(:foreign_key)
    # model_class = options.send(:model_class)
    primary_key = options.send(:primary_key)

    debugger
    define_method(:name) do
      result = options.model_class.where(primary_key => self.attributes[foreign_key])#.limit(1)
    end
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end