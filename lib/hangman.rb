class Hangman

  require 'yaml'

  attr_accessor 

  @@dict = File.readlines('5desk.txt')
  
  def initialize
    reset_game
    new_game
  end

  def reset_game
    @gamestate = {turns: 10, secret_word: '', secret_word_array: [], guessed: []}
    choose_word
    @gamestate[:secret_word_array] = ('_' * @gamestate[:secret_word].length).split('')
  end

  private

  def choose_word
    @gamestate[:secret_word] = @@dict[rand(@@dict.size)].downcase.chomp
    unless @gamestate[:secret_word].length > 4
      choose_word
    end
    @gamestate[:secret_word]
  end

  def draw
    line = @gamestate[:secret_word_array].join(' ')
    puts line
    puts "You already tried: #{@gamestate[:guessed].join(', ')}. Turns left: #{@gamestate[:turns]}"
  end

  def score(guess)
    indices = (0...@gamestate[:secret_word].length).find_all { |i| @gamestate[:secret_word][i,1] == guess }
    indices.each { |ind| @gamestate[:secret_word_array][ind] = guess.to_s }
  end

  def player_guess
    p_guess = gets.chomp.downcase.to_s
    unless p_guess.length == 1
      puts "You can only choose one letter."
      player_guess
    end
    
    if p_guess == '1'
      save_game
      puts "Game saved."
      @gamestate[:turns] += 1
    else
      score(p_guess)
      @gamestate[:guessed] << p_guess
    end
  end

  def check_win
    if !@gamestate[:secret_word_array].include? '_'
      restart('win')
    end
  end

  def restart(reason='lose')
    if reason == 'win'
      puts "Congratulations, you're safe this time."
    else
      puts "How's it hanging? The secret word was #{@gamestate[:secret_word]}"
    end

    puts "Play again? (y/n)"
    answer = gets.chomp.downcase
    answer == 'y' ? initialize : exit
  end

  public

  def new_game
    draw
    until @gamestate[:turns] == 0
      player_guess
      check_win
      draw
      @gamestate[:turns] -= 1
    end
    restart
  end

  def save_game
    File.open('saved.yaml', 'w') do |file|
      file.puts YAML.dump(self)
    end
  end

  def self.load_game
    content = File.open('saved.yaml', 'r') { |file| file.read }
    YAML.load(content)
  end
end

puts "Welcome to Hangman. Press 'y' if you'd like to load the previous game."
game = gets.chomp == 'y' ? Hangman.load_game : Hangman.new
game.new_game
