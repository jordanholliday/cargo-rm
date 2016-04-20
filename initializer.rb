load 'lib/sql_object.rb'

Dir["app/models/*.rb"].each do |klass|
  load klass
  /app\/models\/(.*).rb/.match(klass)[1].capitalize.constantize.finalize!
end
