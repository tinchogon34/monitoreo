class User
  attr_reader :name

  def initialize(args)
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end    
  end

  def self.find(name)
    User.all.detect {|user| user.name == name} || nil
  end

  def self.all
    users = []
    owners = Task.all_untree.map { |task| task.owner }.uniq
    owners.each do |owner|
      passwd = `egrep ^#{owner}: /etc/passwd`.split ":"
      groups = [] 
      `egrep #{owner} /etc/group`.each_line do |line|
        splitted_line = line.split ":"
        next if splitted_line[0] == owner
        groups << {name: splitted_line[0], gid: splitted_line[2]}
      end

      users << User.new({name: owner, uid: passwd[2], gid: passwd[3], info: passwd[4], 
                         home: passwd[5], shell: passwd[6], groups: groups})
    end
    return users    
  end
end
