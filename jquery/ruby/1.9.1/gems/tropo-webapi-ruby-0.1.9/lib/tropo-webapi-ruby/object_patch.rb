# Borrowed from here: http://eigenclass.org/hiki.rb?instance_exec
class Object
  def instance_exec(*args, &block)
    mname = "__instance_exec_#{Thread.current.object_id.abs}"
    class << self; self end.class_eval{ define_method(mname, &block) }
    begin
      ret = send(mname, *args)
    ensure
      class << self; self end.class_eval{ undef_method(mname) } rescue nil
    end
    ret
  end
end