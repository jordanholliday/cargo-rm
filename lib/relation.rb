class Relation

  def initialize(klass)
    @klass = klass
  end

  def params
    @params ||= {params: {}}
  end

  def where(new_params)
    params[:params].merge!(new_params)
    self
  end

  def each(&prc)
    @klass.find_by(@params[:params]).each(&prc)
  end

end

class SQLObject

  def self.where(args)
    Relation.new(self).where(args)
  end

end
