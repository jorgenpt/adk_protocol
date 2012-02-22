require 'tempfile'

module CBuilder
  def c_source; @c_source; end
  def setup_c_source
    @c_source = "#include <stdio.h>\n"
    AdkProtocol.generate_c(:static) do |header, implementation|
      @c_source += header + "\n" + implementation
    end
  end

  def build(*source)
    dir = Dir.mktmpdir('adk_test_build')
    output = File.join(dir, 'adk_test')
    input = File.join(dir, 'adk_test.c')
    File.open(input, 'w') { |f| f.write(source.join("\n")) }

    %x[gcc -o #{output} #{input}]

    assert_equal(0, $?.exitstatus, "Compilation failed with status #{$?.exitstatus}. You can find source here: #{input}")

    output
  end

  ASSERT_REGEX = /^(\S+)\s*(=|!=)\s*(\S+)\s*:\s*(.*)$/
  def parse_asserts(output)
    output.split("\n").each do |assert|
      next if assert.strip.empty?

      assert_not_nil(assert =~ ASSERT_REGEX, 'Could not parse output')
      lh, op, rh, msg = eval($1), $2, eval($3), $4
      case op
      when '='
        assert_equal(lh, rh, msg.strip)
      when '!='
        assert_not_equal(lh, rh, msg.strip)
      end
    end
  end

  def build_and_assert(*source)
    binary = build(*source)
    output = `#{binary} 2>&1`
    assert_equal(0, $?.exitstatus, "Execution failed with status #{$?.exitstatus}")

    parse_asserts(output)
  end
end
