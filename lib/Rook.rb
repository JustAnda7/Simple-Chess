require_relative 'Piece'
require_relative 'MoveFinder'

class Rook < Piece
  include MoveFinder
  attr_reader :moved, :directions, :position, :color
  def initialize(board, position, color)
    super(board, position, color)
    @moved = false
    @directions = [[0,1], [1,0], [0,-1], [-1,0]]
  end

  def possible_move
    @valid_moves = find_possible_move(directions, 'rook')
  end

  def possible_capture
    @valid_captures = find_possible_capture(directions, 'rook')
  end

  def has_moved?
    moved
  end

  def has_moved
    @moved = true
  end
end

class WhiteRook < Rook
  def initialize(board, position)
    super(board, position, 'white')
  end

  def to_s
    "\u2656"
  end
end

class BlackRook < Rook
  def initialize(board, position)
    super(board, position, 'black')
  end

  def to_s
    "\u265c"
  end
end
