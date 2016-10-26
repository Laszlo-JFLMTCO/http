require 'minitest/autorun'
require './lib/guessing_game'

class GuessingGameTest < Minitest::Test

  def test_initialize_class
    assert GuessingGame.new
  end

  def test_game_not_started_default
    refute GuessingGame.new.started
  end

  def test_game_can_be_started
    test_game = GuessingGame.new
    test_game.start
    assert test_game.started
    assert_includes Array(0..100), test_game.mystery_number
  end

  def test_guess_log_stores_previous_guesses
    test_game = GuessingGame.new
    test_game.start
    test_game.guess(100)
    test_game.guess(1)
    assert test_game.guess_log_entry(100)
    assert test_game.guess_log_entry(1)
    assert test_game.last_guess
  end

  def test_last_guess_without_previous_guesses
    test_game = GuessingGame.new
    test_game.start
    assert_equal "No guesses yet...", test_game.last_guess
  end

  def test_guessing_correct_number
    test_game = GuessingGame.new
    test_game.start
    assert_equal "Correct", test_game.guess(test_game.mystery_number)
  end

  def test_start_new_game_good_luck_message
    test_game = GuessingGame.new
    assert_equal "Good Luck!", test_game.start
  end

end