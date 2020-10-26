require "./spec_helper"

describe CliArgsParser do
  # TODO: Write tests

  it "works" do
    root = CliArgsParser::Command.new(
      name: "docker",
      sub_commands: [
        CliArgsParser::Command.new(
          name: "images",
          sub_commands: [
            CliArgsParser::Command.new(
              name: "list"
            )
          ],
        )
      ],
    )

    

    parser = CliArgsParser::Parser.new(root, ["docker", "images", "list"])
    cli_context = parser.parse
  end

  it "sdf" do 
    root = CliArgsParser::Command.new("docker") 

    root.add_sub_command("images") do |images_cmd|
      images_cmd.add_sub_command("list") do |list_cmd|
        list_cmd.action = ->(c : )
      end

    end
    
    root.add_sub_command("volumes") do |images_cmd|
      images_cmd.add_sub_command("list") do |list_cmd|
        list_cmd.action = 
      end
      
    end

    parser = CliArgsParser::Parser.new(root, ["docker", "images", "list"])
    cli_context = parser.parse
  end
end
