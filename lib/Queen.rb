require_relative 'Piece'
require_relative 'MoveFinder'

class Queen < Piece
  include MoveFinder
  attr_reader :moved, :directions, :position, :color
  def initialize(board, position, color)
    super
    @moved = false
    @directions = [-1,0,1].repeated_permutation(2).to_a.reject { |arr| arr == [0,0] }
  end

  def possible_move
    @valid_moves = find_possible_move(directions, 'knight')
  end

  def possible_capture
    @valid_captures = find_possible_capture(directions, 'knight')
  end

  def has_moved?
    moved
  end

  def has_moved
    @moved = true
  end
end

class WhiteQueen < Queen
  def initialize(board, position)
    super(board, position, 'white')
  end

  def to_s
    "\u2655"
  end
end

class BlackQueen < Queen
  def initialize(board, position)
    super(board, position, 'black')
  end

  def to_s
    "\u265b"
  end
end
