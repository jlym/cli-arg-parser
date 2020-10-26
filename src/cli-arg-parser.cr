# TODO: Write documentation for `Cli::Arg::Parser`
module CliArgsParser
  VERSION = "0.1.0"

  # TODO: Put your code here
  class CliContext 
    @string_flags = {} of String => String

    def string(flag : String) : String
    end

    def bool(flag : String) : Bool
    end
    
    def int32(flag : String) : Int32
    end    
  end


  class Flag
    property short : String
    property long : String
    
    def initialize(
      @name : String,
      @short : String = "",
      @long : String = "",
      @required : Bool = false,
      @position : Int32? = nil
    )
    end
  end

  class StringFlag < Flag
  end

  class BoolFlag < Flag
  end

  class IntFlag < Flag
  end

  class StringSetFlag < Flag
    def initialize(
      @name : String,
      @valid_values : Array(String),
      @short : String = "",
      @long : String = "",
      @required : Bool = false,
      @position : Int32 | Nil = nil,      
    )
    end
  end

  class Command
    property name : String
    property flags : Array(Flag)
    property sub_commands : Array(Command)
    property action : Proc(CliContext, Void)?

    def initialize(
      @name : String,
      @flags = [] of Flag,
      @sub_commands = [] of Command,
      @action : Proc(CliContext, Void)? = nil
    )
    end

    def run()      
    end

    def add_sub_command(
      name : String,
      flags = [] of Flag,
      sub_commands = [] of Command,
      action : Proc(CliContext, Void)? = nil): Command

      sub_command = Command.new(
        name, 
        flags: flags,
        sub_commands: sub_commands,
        action: action)
      @sub_commands.push(sub_command)

      sub_command
    end

    def add_string_flag(
      name : String,
      short : String = "",
      long : String = "",
      required : Bool = false,
      position : Int32? = nil
    )

      flag = StringFlag.new(
        name: name,
        short: short,
        long: long,
        required: required,
        position: position
      )
      @flags.push(flag)
    end

  end

  class Parser    
    @current_flags : Array(Flag)
    @args : Array(String)

    def initialize(
      @root_command : Command,
      args : Array(String)
    )
      @current_command = @root_command
      @current_flags = @current_command.flags.dup 
      @cli_context = CliContext.new
      
      @args = args.dup
      
      @string_flags = {} of String => String

      @no_commands_left = false
      @position_args = [] of Flag
    end

    def parse() : CliContext
      current = 0

           
      return @cli_context
    end

    def parse_all_args()
      while @args.empty?
        current_arg = @args[0]

        parsed_command = try_parse_command(current_arg)
        if parsed_command
          next
        end

        parsed_flag = try_parse_flag(current_arg)
        if parsed_flag
          next
        end

        @no_commands_left = true

        parsed_position_arg = try_parse_position_arg(current_arg)
        if parsed_position_arg
          next
        end

        throw "could not parse #{current_arg}"

      end 
    end


    def try_parse_command(arg : String) : Bool
      if @no_commands_left
        return false
      end

      matching_commands = @current_command.commands.select do | command |
        command.name == arg
      end      

      if matching_commands.empty?
        return false
      end

      @current_command = matching_commands.first
      @current_flags.concat(@current_command.flags)

      @position_args = @current_command.flags.select do | flag |
        !flag.position.nil?
      end
      @position_args.sort! do | flag1, flag2 |
        n1 = flag1.position.nil ? -1 : flag1.position
        n2 = flag2.position.nil ? -1 : flag2.position
        n1 <=> n2
      end

      @args.shift

      true
    end

    def try_parse_position_arg(arg : String) Bool
      if @position_args.empty?
        return false
      end

      position_arg = @position_args.shift      
      @string_flags[position_arg.name] = arg

      true
    end

    def try_parse_flag(arg : String) : Bool
      matching_flags = @current_flags.select do | flag |
        if arg.starts_with "--"
          flag.long == arg
        elsif arg.starts_with "-"
          flag.short == arg
        else  
          false 
        end
      end

      if matching_flags.empty?
        return false
      end

      flag = matching_flags.first
      case flag
      when StringFlag
        parse_string_flag_value(flag.name)

      else
        throw "unexpected flag"
      end

      return true
    end

    def parse_string_flag_value(flag_name : String)
      if @args.empty?
        throw "string flag expected an argument"
      end
      
      @string_flags[flag_name] = @args.first
      @args.shift
    end

  end

end
