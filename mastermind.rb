
module GameData
  COLORS = ['b','g','o','p','r','y']
  COLORS_FULL = %w[blue green orange pink red yellow]
  NO_COLORS = 4
  NO_ROUNDS = 4
end


class Board
  include GameData

  def initialize
    @rounds = { pick: Array.new(NO_ROUNDS, ['....']), 
                keys: Array.new(NO_ROUNDS, ['....']) }
  end

  def update_code(code)
    @code = code
  end

  def lost?(counter)
    counter == NO_ROUNDS
  end

  def won?(counter)
    @rounds[:pick][counter-1] == @code
  end

  def insert(pick, counter)
    keys = compare(pick)
    @rounds[:pick][counter] = pick
    @rounds[:keys][counter] = keys
  end

  def compare(pick)
    comparison = { keys: [], pick: [], code: [] }
    check_positions(pick, comparison)
    check_colors(pick, comparison)
    return comparison[:keys]
  end
  
  def check_positions(pick, comp)
    NO_COLORS.times do |i|
      if pick[i] != @code[i]
        comp[:pick] << pick[i]
        comp[:code] << @code[i]
      else
        comp[:keys] << 'O'
      end
    end
  end
      
  def check_colors(pick, comp)
    loop do
      comp[:pick].each_index do |i|
        comp[:code].each_index do |j|
          if comp[:pick][i] == comp[:code][j]
            comp[:keys] << 'o'
            comp[:pick].delete_at(i)
            comp[:code].delete_at(j)
          end
        end
      end
      break if comp[:pick] & comp[:code] == []
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
    select_game_mode
    @player.intro
    @player.select_code
    until @board.lost?(@counter) || @board.won?(@counter)
      @player.pick(@counter)
      @board.show(@counter)
      # puts 'You won.' if @board.won?(@counter)
      # puts 'You lost.' if @board.lost?(@counter)
      @counter += 1
    end
  end

  def select_game_mode
    puts 'Welcome to Mastermind.'
    puts
    puts "Type 'human' if you want to guess the secret code."
    puts "Type 'computer' if you want the computer to do it."
    loop do
      mode = gets.chomp
      if valid_game_mode?(mode)
        mode == 'human' ? 
          @player = Human.new(@board) : 
          @player = Computer.new(@board)
        break
      end
    puts "Invalid input. Type 'player' or 'computer'."
    end
  end

  def valid_game_mode?(mode)
    mode == 'human' || mode == 'computer'
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
    @board.update_code(@code)
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
        @board.update_code(@code)
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
    NO_COLORS.times { pick << COLORS[rand(6)] }
    @board.insert(pick, counter)
  end
end


test = Game.new
test.game