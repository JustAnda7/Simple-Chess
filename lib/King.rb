require_relative 'Piece'
require_relative 'MoveFinder'

class King < Piece
  include MoveFinder
  attr_reader :moved, :directions, :check, :position, :color
  def initialize(board, position, color)
    super
    @moved = false
    @check = false
    @directions = [-1,0,1].repeated_permutation(2).to_a.reject { |arr| arr == [0,0] }
  end

  def possible_move
    @valid_moves = find_possible_move(directions, 'king')
  end

  def possible_capture
    @valid_captures = find_possible_capture(directions, 'king')
  end

  def in_check?
    check
  end

  def has_moved?
    has_moved
  end

  def has_moved
    @moved = true
  end
end

class WhiteKing < King
  def initialize(board, position)
    super(board, position, 'white')
  end

  def to_s
    "\u2654"
  end
end

class BlackKing < King
  def initialize(board, position)
    super(board, position, 'black')
  end

  def to_s
    "\u265a"
  end
end
