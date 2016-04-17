require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def find_by(params)
    query = params
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
        #{query}
    SQL

    # drop headings before mapping
    results.drop(1).map { |result| self.new(result) }
  end
end

class SQLObject
  extend Searchable
end
