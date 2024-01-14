# frozen_string_literal: true

require_relative 'Board'
require_relative 'color'
require_relative 'Human'
require_relative 'Instructions'
require 'io/console'

# gameplay
class Game
  include EscapeSequences
  include Instructions

  # omits 'draw' b/c it is not known whether game should end
  COMMANDS = %w[flip help resign quit exit tutorial instructions].freeze

  attr_reader :board, :to_move, :white, :black

  def initialize(player1, player2)
    @board = Board.new
    @white = player1.color == 'White' ? player1 : player2
    @black = player2.color == 'Black' ? player2 : player1
    @to_move = white
  end

  def play
    board.display(0)
    until board.over?
      if to_move.is_a?(Human)
        print "Enter #{to_move}'s move: "
        input = gets.chomp
        if COMMANDS.include?(input)
          enter_command(input)
          %w[quit exit save resign].include?(input) ? break : next
        elsif input == 'draw'
          if draw_accepted?
            board.display
            board.score = '1/2 - 1/2 Drawn by agreement'
            break
          else
            print_info("#{to_move}: Your draw offer was not accepted.".red)
            next
          end
        end
        unless board.move(input)
          print_info("#{board.error_message}: #{input}. Enter help for info.".red)
          next
        end
      end
      @to_move = to_move == white ? black : white
      board.display
    end
    puts board.move_list
    puts
    puts board.score&.green
  end

  def enter_command(input)
    if input == 'flip'
      board.flip_board
    elsif input == 'resign'
      board.display
      if to_move == white
        board.score = '0-1 Black wins by resignation'
      else
        board.score = '1-0 White wins by resignation'
      end
    elsif %w[quit,  exit].include? input
      board.display
    elsif input == 'help'
      print_info('Input move or enter a command: flip | draw | resign | quit | save | tutorial | instructions'.green)
    # elsif input == 'save'
    #   save_game(self)
    elsif input == 'tutorial'
      show_instructions
      clear_board
      board.display
      show_cursor
    elsif input == 'instructions'
      clear_board
      puts %q(
        - Only enter the target square coordinates for a move. For pawns, nothing else is needed.
        - Begin with K, Q, R, B, or N to move a King, Queen, Rook, Bishop, or Knight, respectively.
        - For a capture, add an x just before the target square.
        - To capture with a pawn, begin with that pawn's file.
        - For kingside castling, enter O-O; for queenside, O-O-O.
        - For en passant, enter capture as though the opponent's pawn had only moved 1 square.
        - Specify the current file or rank of the piece if more than one of that type could make the desired move.
        - To promote a pawn, add =Q, =R, =B, or =N after the target square.
        - Optionally add + or # to indicate check or checkmate respectively. (It will be present in the move list regardless.)
        - Look up Chess Algebraic Notation for more info.

        Press any key to return to game.)
        STDIN.getch
        clear_board
        board.display
        show_cursor
    end
  end

  def draw_accepted?
    opponent = to_move == white ? black : white
    return false if opponent.is_a?(Computer)

    move_up(2)
    print_clear
    puts "#{opponent}: Your opponent has offered a draw. Do you accept? (Yes/No)".green
    answer = gets[0].downcase
    until %w[y n].include? answer
      move_up(3)
      puts_clear
      puts "Invalid input. #{answer} Do you accept your opponent's draw offer? (Yes/No)".red
      answer = gets[0].downcase
    end
    answer == 'y'
  end

  def print_info(message)
    move_up(2)
    print_clear
    puts message
  end
end
