
module GameData
  COLORS = ['b','g','o','p','r','y']
  COLORS_FULL = %w[blue green orange pink red yellow]
  NO_COLORS = 4
  NO_ROUNDS = 12
end


class Board
  include GameData
  attr_accessor :rounds

  def initialize
    @rounds = { pick: Array.new(NO_ROUNDS, ['....']), 
                keys: Array.new(NO_ROUNDS, ['....']),
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
    comparison = compare(pick)
    @rounds[:pick][counter] = pick
    @rounds[:keys][counter] = comparison[:keys]
    @rounds[:pos][counter] = comparison[:pos]
    @rounds[:col][counter] = comparison[:col]
  end

  def compare(pick)
    comparison = { keys: [], pos: [], col: [] }
    check_positions(pick, comparison)
    check_colors(pick, comparison)
    return comparison
  end
  
  def check_positions(pick, comp)
    pick.each_index do |i|
      if pick[i] == @code[i]
        comp[:keys] << 'O'
        comp[:pos] << i
      end
    end
  end
      
  def check_colors(pick, comp)
    pick.each_index do |i|
      next if comp[:pos].include?(i)
      @code.each_index do |j|
        next if comp[:col].include?(j) || comp[:pos].include?(j)
        if pick[i] == @code[j]
          comp[:keys] << 'o'
          comp[:col] << j
        end
      end
    end
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
end


class Game
  include GameData

  def initialize
    @board = Board.new
    @counter = 0
    @player = 0
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
  
  def intro
    puts 'Welcome to Mastermind.'
    puts
    puts "Type 'human' if you want to guess the secret code."
    puts "Type 'computer' if you want the computer to do it."
  end

  def select_game_mode
    loop do
      @mode = gets.chomp
      if valid_game_mode?(@mode)
        @mode == 'human' ? 
          @player = Human.new(@board) : 
          @player = Computer.new(@board)
        break
      end
    puts "Invalid input. Type 'human' or 'computer'."
    end
  end

  def valid_game_mode?(mode)
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
    puts "Please pick #{NO_COLORS} colors. Choose between:"
    (COLORS.size).times { |i| print "#{COLORS_FULL[i]}(#{COLORS[i]}) " }
    puts
    puts
    puts "O= Correct color in correct position; o= Correct color."
    puts
  end

  def select_code
    NO_COLORS.times { @code << COLORS[rand(6)] }
    @board.import_code(@code)
  end

  def pick(counter)
    loop do
      pick = gets.chomp.split('')
      if valid?(pick)
        @board.insert(pick, counter)
        break
      end
      example = []
      NO_COLORS.times { example << COLORS[rand(6)] }
      puts "Invalid input. Pick #{NO_COLORS} colors, e.g.: '#{example}'."
    end
  end

  def valid?(pick)
    pick.size == NO_COLORS && pick.all? { |i| COLORS.include?(i) }
  end
end


class Computer
  include GameData

  def initialize(board)
    @board = board
  end

  def intro
    puts
  end

  def select_code
    puts "Please pick #{NO_COLORS} colors. Choose between:"
    (COLORS.size).times { |i| print "#{COLORS_FULL[i]}(#{COLORS[i]}) " }
    puts
    loop do
      @code = gets.chomp.split('')
      if valid?(@code)
        @board.import_code(@code)
        break
      end
      example = []
      NO_COLORS.times { example << COLORS[rand(6)] }
      puts "Invalid input. Pick #{NO_COLORS} colors, e.g.: '#{example}'."
    end
  end

  def valid?(code)
    @code.size == NO_COLORS && @code.all? { |i| COLORS.include?(i) }
  end

  def pick(counter)
    pick = []
    rounds = @board.rounds
    NO_COLORS.times { pick << COLORS[rand(6)] }
    if counter > 0
      rounds[:pos][counter-1].each { |i| pick[i] = @code[i] }
      samples = []
      rounds[:col][counter-1].each do |i|
        samples << ((0..NO_COLORS-1).to_a - rounds[:pos][counter-1] - samples).sample
        pick[samples[-1]] = @code[i]
      end
    end
    @board.insert(pick, counter)
  end
end


test = Game.new
test.game