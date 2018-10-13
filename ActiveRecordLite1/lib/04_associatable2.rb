require_relative '03_associatable'
require 'byebug'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      foreign_key_val1 = self.attributes[through_options.foreign_key]

      through_object = through_options.model_class.where({through_options.primary_key => foreign_key_val1}).first

      ######
      # debugger

      foreign_key_val2 = through_object.attributes[source_options.foreign_key]

      source_object = source_options.model_class.where({source_options.primary_key => foreign_key_val2}).first
    end

  end
end
