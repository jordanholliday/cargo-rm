require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

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
