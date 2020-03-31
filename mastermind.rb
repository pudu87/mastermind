
module GameData
  COLORS = ['b','g','o','p','r','y']
  COLORS_FULL = %w[blue green orange pink red yellow]
  NO_COLORS = 4
  NO_ROUNDS = 12
end

class Board
  include GameData

  def initialize
    @code = []
    @rounds = { pick: Array.new(NO_ROUNDS, ['....']), 
                keys: Array.new(NO_ROUNDS, ['....']) }
  end

  def select_code
    NO_COLORS.times { @code << COLORS[rand(6)] }
  end

  def lost?(counter)
    counter == NO_ROUNDS
  end

  def won?(counter)
    @rounds[:pick][counter] == @code
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
  end

  def start
    intro
    @board.select_code
    until @board.lost?(@counter) || @board.won?(@counter)
      pick
      @board.show(@counter)
      puts 'You won.' if @board.won?(@counter)
      puts 'You lost.' if @board.lost?(@counter)
      @counter += 1
    end
  end

  def intro
    puts; puts 'Welcome to Mastermind.'
    puts "Please pick #{NO_COLORS} colors. Choose between:"
    (COLORS.size).times { |i| print "#{COLORS_FULL[i]}(#{COLORS[i]}) " }
    puts
    puts; puts "O= Correct color in correct position; o= Correct color."
    puts
  end

  def pick
    loop do
      pick = gets.chomp.split('')
      if valid?(pick)
        @board.insert(pick, @counter)
        break
      end
      example = NO_COLORS.times { @code << COLORS[rand(6)] }
      puts "Invalid input. Pick #{NO_COLORS} colors, e.g.: '#{example}'."
    end
  end

  def valid?(pick)
    pick.size == NO_COLORS && pick.all? { |i| COLORS.include?(i) }
  end
end


test = Game.new
test.start