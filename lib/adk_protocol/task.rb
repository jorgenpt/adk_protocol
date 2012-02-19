require 'rake/tasklib'

require 'fileutils'

require 'adk_protocol'

# Based on https://github.com/rdoc/rdoc/blob/master/lib/rdoc/task.rb
# Also: https://github.com/jimweirich/rake/blob/master/lib/rake/testtask.rb
class AdkProtocol::Task < Rake::TaskLib
  attr_accessor :name

  attr_accessor :java_dir
  attr_accessor :java_package
  attr_accessor :c_dir
  attr_accessor :c_name

  def initialize(name = :adk_protocol)
    defaults

    @name = name

    yield self if block_given?

    define
  end

  def defaults
    @name = :adk_protocol
    @java_dir = 'gen/java'
    @java_package = 'com.bitspatter.adk_protocol'
    @c_dir = 'gen/c'
    @c_name = 'adk_protocol'
  end

  def task_description
    'Generate Java & C'
  end

  def c_task_description
    'Generate C'
  end

  def java_task_description
    'Generate Java'
  end

  def c_task_name
    "#{name}_c"
  end

  def java_task_name
    "#{name}_java"
  end

  def define
    desc task_description
    task name

    desc c_task_description
    task c_task_name do
      AdkProtocol.generate_c do |header, implementation|
        FileUtils.mkdir_p(@c_dir)
        base_path = File.join(@c_dir, @c_name)
        constant_guard = "_#{base_path}.h_".upcase.gsub(/[^A-Z_]/, '_')

        File.open("#{base_path}.h", 'w') do |file|
          file.write("#ifndef #{constant_guard}\n")
          file.write("#define #{constant_guard}\n")
          file.write(header)
          file.write("\n")
          file.write("#endif /* #{constant_guard} */\n")
        end

        File.open("#{base_path}.c", 'w') do |file|
          file.write("#include \"#{@c_name}.h\"\n")
          file.write(implementation)
          file.write("\n")
        end
      end
    end

    desc java_task_description
    task java_task_name do
      AdkProtocol.generate_java(@java_package) do |classname, code|
        package_path = File.join(@java_dir, @java_package.gsub('.', '/'))
        FileUtils.mkdir_p(package_path)
        File.open(File.join(package_path, "#{classname}.java"), 'w') do |file|
          file.write(code)
        end
      end
    end

    task name => [c_task_name, java_task_name]

    self
  end
end
