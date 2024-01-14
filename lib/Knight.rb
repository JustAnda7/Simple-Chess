require_relative 'Piece'
require_relative 'MoveFinder'

class Knight < Piece
  include MoveFinder
  attr_reader :moved, :directions, :position, :color
  def initialize(board, position, color)
    super
    @moved = false
    @directions = [[2,1], [1,2], [-1,2], [-2,1], [-2,-1], [-1,-2], [1,-2], [2,-1]]
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

class WhiteKnight < Knight
  def initialize(board, position)
    super(board, position, 'white')
  end

  def to_s
    "\u2658"
  end
end

class BlackKnight < Knight
  def initialize(board, position)
    super(board, position, 'black')
  end

  def to_s
    "\u265e"
  end
end
