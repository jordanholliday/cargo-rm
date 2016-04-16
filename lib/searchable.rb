require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    where_line = params
                .keys
                .map { |key| "#{key} = ?" }
                .join(" AND ")

    value_array = params.values

    results = DBConnection.execute2(<<-SQL, *value_array)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL

    results.drop(1).map { |result| self.new(result) }
  end
end

class SQLObject
  extend Searchable
end
