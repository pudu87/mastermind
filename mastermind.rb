
module GameData
  COLORS = ['b','g','o','p','r','y']
  COLORS_FULL = %w[blue green orange pink red yellow]
  NO_COLORS = 4
  NO_ROUNDS = 12
  
  def color_intro
    puts "Please pick #{NO_COLORS} colors. Choose between:"
    (COLORS.size).times { |i| print "#{COLORS_FULL[i]}(#{COLORS[i]}) " }
    puts
  end

  def color_example
    example = []
    NO_COLORS.times { example << COLORS[rand(6)] }
    puts "Invalid input. Pick #{NO_COLORS} colors, e.g.: '#{example}'."
  end
end


class Game
  include GameData

  def initialize
    @board = Board.new
    @counter = 0
  end

  def game
    intro
    select_game_mode
    @player.intro
    @player.select_code
    until @board.lost?(@counter) || @board.won?(@counter)
      @player.pick(@counter)
      @board.show(@counter)
      @counter += 1
    end
    outro
  end

  private
  
  def intro
    puts 'Welcome to Mastermind.'
    puts '---------------------'
    puts "Type 'human' if you want to guess the secret code."
    puts "Type 'computer' if you want the computer to do it."
  end

  def select_game_mode
    @mode = gets.chomp
    until valid_mode?(@mode)
      @mode = gets.chomp
      puts "Invalid input. Type 'human' or 'computer'."
    end
    @mode == 'human' ? @player = Human.new(@board) : @player = Computer.new(@board)
  end

  def valid_mode?(mode)
    mode == 'human' || mode == 'computer'
  end

  def outro
    puts @board.won?(@counter) == (@mode == 'human') ? 'You won.' : 'Computer won.'
  end
end


class Human
  include GameData

  def initialize(board)
    @code = []
    @board = board
  end

  def intro
    puts
    color_intro
    puts "O= Correct color in correct position; o= Correct color."
  end

  def select_code
    NO_COLORS.times { @code << COLORS[rand(6)] }
    @board.import_code(@code)
  end

  def pick(counter)
    pick = gets.chomp.split('')
    until valid?(pick)
      pick = gets.chomp.split('')
      color_example
    end
    @board.insert(pick, counter)
  end

  private

  def valid?(pick)
    pick.size == NO_COLORS && pick.all? { |i| COLORS.include?(i) }
  end
end


class Computer
  include GameData

  def initialize(board)
    @board = board
  end

  def intro; end

  def select_code
    color_intro
    @code = gets.chomp.split('')
    until valid?(@code)
      @code = gets.chomp.split('')
      color_example
    end
    @board.import_code(@code)
  end

  def pick(counter)
    pick = []
    rounds = @board.rounds
    NO_COLORS.times { pick << COLORS[rand(6)] }
    place_pos(counter, pick, rounds)
    place_col(counter, pick, rounds)
    @board.insert(pick, counter)
  end

  private

  def valid?(code)
    @code.size == NO_COLORS && @code.all? { |i| COLORS.include?(i) }
  end

  def place_pos(counter, pick, rounds)
    rounds[:pos][counter-1].each { |i| pick[i] = @code[i] }
  end

  def place_col(counter, pick, rounds)
    samples = []
    rounds[:col][counter-1].each do |i|
      samples << ((0..NO_COLORS-1).to_a - rounds[:pos][counter-1] - samples).sample
      pick[samples[-1]] = @code[i]
    end
  end
end


class Board
  include GameData
  attr_accessor :rounds

  def initialize
    @rounds = { pick: Array.new(NO_ROUNDS, ['....']), 
                keys: Array.new(NO_ROUNDS, []),
                pos: Array.new(NO_ROUNDS, []),
                col: Array.new(NO_ROUNDS, []) 
              }
  end

  def import_code(code)
    @code = code
  end

  def lost?(counter)
    counter == NO_ROUNDS
  end

  def won?(counter)
    @rounds[:pick][counter-1] == @code
  end

  def insert(pick, counter)
    compare = { keys: [], pos: [], col: [] }
    check_positions(pick, compare)
    check_colors(pick, compare)
    @rounds[:pick][counter], @rounds[:keys][counter] = pick, compare[:keys]
    @rounds[:pos][counter], @rounds[:col][counter] = compare[:pos], compare[:col]
  end

  def show(counter)
    puts
    won?(counter) || lost?(counter) ? 
      @code.each { |i| print i } : 
      NO_COLORS.times { print 'X' }
    puts
    puts '----'
    (NO_ROUNDS-1).downto(0) do |i|
      @rounds[:pick][i].each { |j| print j }
      print ' '
      @rounds[:keys][i].each { |j| print j }
      puts
    end
    puts
  end

  private
  
  def check_positions(pick, comp)
    pick.each_index do |i|
      if pick[i] == @code[i]
        comp[:keys] << 'O'
        comp[:pos] << i
      end
    end
  end
      
  def check_colors(pick, comp)
    col_pick = []
    pick.each_index do |i|
      next if comp[:pos].include?(i)
      @code.each_index do |j|
        next if comp[:col].include?(j) || 
          comp[:pos].include?(j) || col_pick.include?(i)
        if pick[i] == @code[j]
          comp[:keys] << 'o'
          comp[:col] << j
          col_pick << i
        end
      end
    end
  end
end


test = Game.new
test.game