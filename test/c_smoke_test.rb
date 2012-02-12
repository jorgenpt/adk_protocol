require File.absolute_path(File.dirname(__FILE__) + '/test_helpers')

class CSmokeTest < Test::Unit::TestCase
  include CBuilder

  def test_simple_program
    simple_success = build('int main() { return 0; }')
    assert_true(File.exist?(simple_success))
    assert_true(system(simple_success))

    simple_error = build('int main() { return 1; }')
    assert_true(File.exist?(simple_error))
    assert_false(system(simple_error))
  end
end
