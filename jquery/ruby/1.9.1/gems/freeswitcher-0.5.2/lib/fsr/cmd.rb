module FSR
  module Cmd
    class Command
      DEFAULT_OPTIONS = {
        :origination_caller_id_name => FSR::DEFAULT_CALLER_ID_NAME,
        :origination_caller_id_number => FSR::DEFAULT_CALLER_ID_NUMBER,
        :originate_timeout => 30,
        :ignore_early_media => true
      }

      protected
      def default_options(args = {}, defaults = nil, &block)
        opts = if defaults.nil?
          DEFAULT_OPTIONS.merge(args)
        else
          raise(ArgumentError, "defaults argument must ba a hash") unless defaults.kind_of?(Hash)
          defaults.merge(args)
        end
        yield opts if block_given?
      end

    end

    COMMANDS = {}
    LOAD_PATH = [Pathname(FSR::ROOT).join( "fsr", "cmd")]

    def self.register(command, obj)
      COMMANDS[command.to_sym] = obj

      code = "def %s(*args, &block) COMMANDS[%p].new(self, *args, &block) end" % [command, command]
      Cmd.module_eval(code)
    end

    def self.list
      COMMANDS.keys
    end

    def self.load_command(command, force_reload = false)
      # If we get a path specification and it's an existing file, load it
      if File.file?(command)
        if force_reload
          return load(command)
        else
          return require(command)
        end
      end
      Log.debug "Trying load paths"
      # If we find a file named the same as the command passed in LOAD_PATH, load it
      if found_command_path = LOAD_PATH.detect { |command_path| command_path.join("#{command}.rb").file? }
        command_file = found_command_path.join(command)
        Log.debug "Trying to load #{command_file}"
        if force_reload
          load command_file.to_s + ".rb"
        else
          require command_file
        end
      else
        raise "#{command} not found in #{LOAD_PATH.join(":")}"
      end
    end

    # Load all of the commands we find in Cmd::LOAD_PATH
    def self.load_all(force_reload = false)
      LOAD_PATH.each do |load_path|
        Dir[load_path.join("*.rb").to_s].each { |command_file| load_command(command_file, force_reload) }
      end
      list
    end

    def commands
      FSR::Cmd.list
    end
  end
end
FSC = FSR::Cmd
