require_relative 'Piece'
require_relative 'MoveFinder'

class Bishop < Piece
  include MoveFinder
  attr_reader :moved, :directions, :position, :color
  def initialize(board, position, color)
    super
    @moved = false
    @directions = [[1,1], [1,-1], [-1,-1], [-1,1]]
  end

  def possible_move
    @valid_moves = find_possible_move(directions, 'bishop')
  end

  def possible_capture
    @valid_captures = find_possible_capture(directions, 'bishop')
  end

  def has_moved?
    moved
  end

  def has_moved
    @moved = true
  end
end

class WhiteBishop < Bishop
  def initialize(board, position)
    super(board, position, 'white')
  end

  def to_s
    "\u2657"
  end
end

class BlackBishop < Bishop
  def initialize(board, position)
    super(board, position, 'black')
  end

  def to_s
    "\u265d"
  end
end
