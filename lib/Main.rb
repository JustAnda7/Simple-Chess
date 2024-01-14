# frozen_string_literal: true

require_relative 'Game'
require_relative 'color'
require_relative 'EscapeSequences'

include EscapeSequences

colors = ['White', 'Black'].shuffle

prompt = <<~HEREDOC

  #{'Chess!'.green}

  Press 'y' to continue playing the game.
  Press 'n' to quit playing the game.

HEREDOC

puts prompt

user_choice = gets.chomp

move_up(10)
puts_clear

def game_driver(user_choice, colors)
  unless user_choice == 'n'
    player1 = Human.new(colors[0])
    player2 = Human.new(colors[1])
    game = Game.new(player1, player2)
    2.times { puts }
    game.play
    puts_clear
    puts 'Do you want to play a game? [y] or [n]'
    user_choice = gets.chomp.strip.downcase
    until %w[y n].include?(replay)
      move_up(2)
      print_clear
      puts "Invalid input: #{replay} Please enter y or n".red
      user_choice = gets.chomp
    end
  end
end

game_driver(user_choice, colors) unless user_choice == 'n'

puts "Thank you for playing"
puts_clear
puts
