require_relative 'db_connection'
require_relative '01_sql_object'
require 'byebug'

module Searchable
  def where(params)
    where_clause = params.keys.join("= ? AND ") + "= ?"

    results = DBConnection.execute(<<-SQL, params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_clause}
    SQL

    self.parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
