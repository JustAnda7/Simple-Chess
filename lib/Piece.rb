class Piece

  private
    attr_reader :color, :board

  public

  attr_reader :history, :valid_moves, :valid_captures
  attr_accessor :position

  def initialize(board, position, color)
    @board = board
    @color = color
    @position = position
    @valid_moves = []
    @valid_captures = []
    @history = []
  end

  # def valid_move?(valid, next_pos)
  #   # return true if valid.include?(next_pos)
  #   valid.include?(next_pos) ? true : false
  # end

  def white?
    color == 'white'
  end
end
