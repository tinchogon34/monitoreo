class Task
  attr_reader :owner, :pid, :cpu, :mem, :vsz, :rss, :tty, :stat, :start, :time, :command
  attr_accessor :errors, :prio, :childs, :removable

  def initialize(args)
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end    

    self.prio = Process.getpriority(Process::PRIO_PROCESS, self.pid) rescue 0    
    self.errors =[]
    self.childs = []
  end

  def self.all
    tasks = parse_ps

    tasks.each do |task|
      `ps h --ppid #{task.pid} -o pid`.each_line do |pid|
        ctask = tasks.detect {|t| t.pid == pid.to_i}
        next if not ctask
        ctask.removable = true
        task.childs << ctask
      end
    end

    tasks.delete_if {|task| task.removable}
    
    return tasks
  end

  def self.all_untree
    parse_ps
  end

  def self.all_by_user(name)
    tasks = parse_ps

    tasks_user = tasks.select{|task| task.owner == name}

    return nil if not tasks_user

    tasks_user.each do |task|
      `ps h --ppid #{task.pid} -o pid`.each_line do |pid|
        ctask = tasks.detect {|t| t.pid == pid.to_i}
        next if not ctask
        task.childs << ctask
      end
    end

    return tasks_user
  end

  def self.find(pid)
    tasks = all_untree

    task = tasks.detect { |task| task.pid == pid.to_i }
    return nil if not task
    `ps h --ppid #{task.pid} -o pid`.each_line do |pid|
        ctask = tasks.detect {|t| t.pid == pid.to_i}
        next if not ctask
        task.childs << ctask
    end

    return task
  end

  def save
    pid = nil
    
    if `which #{self.command.strip.split(' ')[0]}`.empty?
      self.errors << "Command not found"
      return false  
    end

    begin
      pid = Process.spawn self.command
      Process.detach(pid)
    rescue Exception => e
      self.errors << e.message
      return false
    end

    new_task = Task.find(pid)
    new_task.instance_variables.each do |v|
      instance_variable_set(v,new_task.instance_variable_get(v))
    end

    return true
  end

  def update(args)
    begin
      Process.setpriority Process::PRIO_PROCESS, self.pid, args[:prio].to_i if args[:prio]
    rescue Exception => e
      self.errors << e.message
      return false
    end

    begin
      Process.setpgid self.pid, args[:gid].to_i if args[:gid]
    rescue Exception => e
      self.errors << e.message
      return false
    end   

    return true
  end

  def destroy
    begin
      Process.kill :KILL, self.pid
    rescue Exception => e
      self.errors << e.message
      return false
    end

    return true
  end

  def as_json(options={})
    options[:except] ||= ["errors", "removable"]
    super(Hash[options.to_a.reverse])
  end

  private

  def self.parse_ps
    tasks = []
    lines = `ps faux --no-headers | less -+S`.each_line do |line|
      splitted_line = line.split(" ")
      tasks << Task.new({owner: splitted_line.shift, pid: splitted_line.shift.to_i, 
                         cpu: splitted_line.shift, mem: splitted_line.shift, 
                         vsz: splitted_line.shift, rss: splitted_line.shift, 
                         tty: splitted_line.shift, stat: splitted_line.shift, 
                         start: splitted_line.shift, time: splitted_line.shift,
                         command: splitted_line.join(" ").gsub('\\_ ','')})

    end
    return tasks
  end
end