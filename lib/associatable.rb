require_relative 'searchable'
require 'active_support/inflector'

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
    class_name.constantize.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = (  options[:foreign_key] ?
                      options[:foreign_key] :
                      (name.to_s + "_id").to_sym )

    @primary_key = (  options[:primary_key] ?
                      options[:primary_key] :
                      "id".to_sym )

    @class_name = (   options[:class_name] ?
                      options[:class_name] :
                      name.to_s.camelcase )
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = (  options[:foreign_key] ?
                      options[:foreign_key] :
                      (self_class_name.to_s.downcase + "_id").to_sym )

    @primary_key = (  options[:primary_key] ?
                      options[:primary_key] :
                      :id )
    @class_name = (   options[:class_name] ?
                      options[:class_name] :
                      name.to_s.singularize.camelcase )
  end
end

module Associatable
  def belongs_to(name, options = {})
    # options = BelongsToOptions.new(name, options)
    assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do
      foreign_key = options.send(:foreign_key)

      target_id = self.send(foreign_key)
      target_class = options.send(:model_class)

      target_class.where(id: target_id).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)

    define_method(name) do
      foreign_key = options.send(:foreign_key).to_s
      target_class = options.send(:model_class)
      target_class.where(foreign_key => self.id)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      #set up options: first, get the assoc options for origin class
      through_options = self.class.assoc_options[through_name]
      # then call model class on those options above to get the next set of assoc options
      source_options = through_options.model_class.assoc_options[source_name]
      #figure out what foreign key you are looking for by sending :foreign key to
      #through options from origin class
      join_fk = through_options.send(:foreign_key)
      # get the original object's id
      origin_id = self.send(join_fk)
      # find the join class, this step might be redundant after above
      join_class = through_options.send(:model_class)
      # find primary key of object in join class
      join_object_id = join_class.where(id: origin_id).first.id
      # find what column you're looking for in the destination class table
      destination_fk = source_options.send(:foreign_key)
      destination_id = join_class.where(id: origin_id).first.send(destination_fk)
      destination_class = source_options.send(:model_class)
      destination_class.where(id: destination_id).first
    end
  end
end

class SQLObject
  extend Associatable
end
