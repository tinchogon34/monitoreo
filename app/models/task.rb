class Task
  attr_reader :owner, :pid, :cpu, :mem, :vsz, :rss, :tty, :stat, :start, :time, :command, :errors
  attr_writer :errors

  def initialize(args)
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def self.all
    tasks = []
    lines = `ps faux`.lines[1..-1]
    lines.each do |line|
      splitted_line = line.split(" ")
      owner = splitted_line.shift
      pid = splitted_line.shift
      cpu = splitted_line.shift
      mem = splitted_line.shift
      vsz = splitted_line.shift
      rss = splitted_line.shift
      tty = splitted_line.shift
      stat = splitted_line.shift
      start = splitted_line.shift
      time = splitted_line.shift
      command = splitted_line.join(" ")
      tasks << Task.new({owner: owner, pid: pid.to_i, cpu: cpu, mem: mem, 
                         vsz: vsz, rss: rss, tty: tty, stat: stat, start: start,
                         time: time, command: command})
    end
    return tasks
  end

  def self.find(pid)
    self.all.detect { |task| task.pid == pid.to_i }
  end

  def save
    self.errors ||= []
    begin
      pid = Process.spawn self.command
      Process.detach pid
    rescue Exception => e
      self.errors << e.message
      return false
    end

    #return system(self.command+"#{' &' if self.command[-1] != '&'}")
  end

  def update(args)
    self.errors ||= []

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
    self.errors ||= []

    begin
      Process.kill :KILL, self.pid
    rescue Exception => e
      self.errors << e.message
      return false
    end

    return true
  end
end