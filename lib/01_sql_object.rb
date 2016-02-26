require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  # include Searchable

  def self.columns
    return @all_columns unless @all_columns.nil?
    @all_columns = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    @all_columns = @all_columns[0].map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) do
        attributes[column]
      end

      define_method("#{column}=") do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    rows = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    self.parse_all(rows.drop(1))
  end

  def self.parse_all(results)
    # all_records = []
    #
    # results.each do |result|
    #   all_records << self.new(result)
    # end
    #
    # all_records

    results.map { |result| self.new(result) }
  end

  def self.find(id)
    result = DBConnection.execute2(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL

    return nil if result.length != 2
    self.new(result[1])
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end

      self.send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    values_array = []

    attributes.each do |attribute, val|
      values_array << val
    end

    values_array
  end

  def insert
    columns_string = self.class.columns[1..-1].join(",")
    qm_string = self.class.columns[1..-1].map { |col| "?" }
    qm_string = qm_string.join(",")
    DBConnection.execute2(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{columns_string})
      VALUES
        (#{qm_string})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns[1..-1]
                .map { |attr_name| "#{attr_name} = ?"}
                .join(",")
    value_array = attribute_values[1..-1] << attribute_values[0]
    puts value_array
    DBConnection.execute2(<<-SQL, *value_array)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
       id = ?
    SQL
  end

  def save
    id ? update : insert
  end
end
