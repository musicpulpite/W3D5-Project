require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.
require 'byebug'

class SQLObject
  def self.columns
    return @columns if @columns
    entries_array = DBConnection.execute2(<<-SQL)
      SELECT * FROM #{self.table_name} LIMIT 1
    SQL

    @columns = entries_array.first.map {|column| column.to_sym}
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) { attributes[column] }

      define_method("#{column}=") do |new_val|
        attributes[column] = new_val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    self.name.underscore + "s"
  end

  def self.all
    entries_array = DBConnection.execute(<<-SQL)
      SELECT * FROM #{self.table_name}
    SQL

    self.parse_all(entries_array)
  end

  def self.parse_all(results)
    results.map {|params| self.new(params)}
  end

  def self.find(id)
    entry = DBConnection.execute(<<-SQL, id)
      SELECT * FROM #{self.table_name} WHERE id = ?
    SQL

    return nil if entry.empty?

    self.parse_all(entry).first
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name)

      send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values
  end

  def insert

    col_names = "(" + self.attributes.keys.join(",") + ")"
    n = self.attribute_values.length
    question_marks = "(" + (["?"]*n).join(",") + ")"

    # debugger

    DBConnection.execute(<<-SQL, *self.attribute_values)
      INSERT INTO #{self.class.table_name} #{col_names} VALUES #{question_marks}
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update

    col_names = (self.class.columns[1..-1]).join("= ?, ") + "= ?"

    DBConnection.execute(<<-SQL, self.attribute_values.rotate )
      UPDATE #{self.class.table_name} SET #{col_names} WHERE id = ?
    SQL
  end

  def save
    id.nil? ? self.insert : self.update
  end
end
