class User
  attr_reader :name

  def initialize(args)
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end    
  end

  def self.all
    users = []
    owners = Task.all.map { |task| task.owner }.uniq
    owners.each do |owner|
      users << User.new({name: owner})
    end
    return users    
  end
end
