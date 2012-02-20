require 'fileutils'

require 'adk_protocol/task'

JAVA_OUT = Dir.mktmpdir
JAVA_OUT_SRC = File.join(JAVA_OUT, 'src')
JAVA_OUT_BIN = File.join(JAVA_OUT, 'bin')

AdkProtocol::Task.new do |adk|
  adk.java_dir = JAVA_OUT_SRC
end

module JavaBuilder
  def java_class_path
    JAVA_OUT_BIN
  end

  def generate_java_source
    Rake::Task["adk_protocol_java"].invoke
  end

  def build_java_source
    FileUtils.mkdir_p(JAVA_OUT_BIN)
    input = Dir[File.join(JAVA_OUT_SRC, '**', '*.java')]
    %x[javac -d #{JAVA_OUT_BIN} "#{input.join('" "')}"]
    output = Tempfile.new('adk_test')

    assert_equal(0, $?.exitstatus, "Compilation failed with status #{$?.exitstatus}.")

    $CLASSPATH << JAVA_OUT_BIN if defined?(JRUBY_VERSION)
  end
end
