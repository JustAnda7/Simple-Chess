require_relative 'Piece'

class Pawn < Piece

  private
  attr_reader :moved

  public

  attr_accessor :en_passant, :en_passant_capture, :color, :position
  def initialize(board, position, color)
    super
    @moved = false
  end

  def possible_move(dir)
    moves = []
    file = position[0]
    rank = position[1] + (1*dir)
    unless has_moved?
      moves << [file, rank+1*dir] if board.chessboard[file][rank+1*dir].nil? && board.chessboard[file][rank].nil?
    end
    moves <<  [file, rank] if rank.between?(0,7) && board.chessboard[file][rank].nil?
    @valid_moves = moves
  end

  def possible_capture(dir)
    captures = []
    file = position[0]
    rank = position[1]+1*dir
    if rank.between?(0,7)
      captures << [file-1, rank] if (file-1).between?(0,7) && board.chessboard[file][rank]&.white? != white?
      captures << [file+1, rank] if (file+1).between?(0,7) && board.chessboard[file][rank]&.white? != white?
    end
    @valid_captures = captures
  end

  def has_moved?
    moved
  end

  def has_moved
    @moved = true
  end
end

class WhitePawn < Pawn
  def initialize(board, position)
    super(board, position, 'white')
  end

  def possible_move
    super(1)
  end

  def possible_capture
    super(1)
  end

  def add_en_passant(file)
    @en_passant = [file, 5]
    @en_passant_capture = [file, 4]
  end

  def remove_en_passant
    @en_passant = nil
  end

  def to_s
    "\u2659"
  end
end

class BlackPawn < Pawn
  def initialize(board, position)
    super(board, position, 'black')
  end

  def possible_move
    super(-1)
  end

  def possible_capture
    super(-1)
  end

  def add_en_passant(file)
    @en_passant = [file, 2]
    @en_passant_capture = [file, 3]
  end

  def remove_en_passant
    @en_passant = nil
  end

  def to_s
    "\u265f"
  end
end
