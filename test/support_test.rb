require 'minitest/autorun'
require "./lib/support"

class SupportTest < Minitest::Test

  def test_capitalize_single_word_not_capitalized
    assert_equal "Capitalized", capitalize("capitalized")
  end

  def test_capitalize_single_word_all_upper_case
    assert_equal "Capitalized", capitalize("CAPITALIZED")
  end

  def test_capitalize_two_word_with_dash_between_not_capitalized
    assert_equal "Content-Length", capitalize("content-length")
  end

  def test_capitalize_two_word_with_dash_between_capitalized
    assert_equal "Content-Length", capitalize("Content-Length")
  end

end