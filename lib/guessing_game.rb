require 'pry'

class GuessingGame

  attr_reader :started,
              :mystery_number,
              :guess_log

  def initialize
    @started = false
    clear_everything
  end

  def clear_everything
    clear_mystery_number
    clear_guess_log
  end

  def clear_mystery_number
    @mystery_number = nil
  end

  def clear_guess_log
    @guess_log = {}
  end

  def pick_a_number(max)
    random_number_generator = Random.new
    @mystery_number = random_number_generator.rand(max + 1)
  end

  def start
    return if started
    clear_everything
    pick_a_number(100)
    @started = true
    "Good Luck!"
  end

  def guess_evaluation(target, guess)
    return "Too Low" if target > guess
    return "Too High" if target < guess
    @started = false
    "Correct"
  end

  def guess(number)
    return if !started
    @guess_log[number] = "#{guess_evaluation(mystery_number, number)}"
  end

  def guess_log_entry(number)
    guess_log[number]
  end

  def last_guess
    return "No guesses yet..." if guess_log.keys.last.nil?
    "#{guess_log.keys.count} guess(es) until now.\nMost recent guess was number #{guess_log.keys.last} => It was #{guess_log_entry(guess_log.keys.last)}"
  end

end