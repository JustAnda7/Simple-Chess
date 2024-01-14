module MoveFinder
  def find_possible_move(dir, piece)
    moves = []
    dir.each do |direction|
      file = position[0] + direction[0]
      rank = position[1] + direction[1]
      if ['knight', 'king'].include?(piece)
        moves << [file, rank] if file.between?(0,7) && rank.between?(0,7) && board.chessboard[file][rank].nil?
      else
        while file.between?(0,7) && rank.between?(0,7) && board.chessboard[file][rank].nil?
          moves << [file, rank]
          file += direction[0]
          rank += direction[1]
        end
      end
    end
    moves
  end

  def find_possible_capture(dir, piece)
    captures = []
    dir.each do |direction|
      file = position[0] + direction[0]
      rank = position[1] + direction[1]
      if ['knight', 'king'].include?(piece)
        captures << [file, rank] if file.between?(0,7) && rank.between?(0,7) && board.chessboard[file][rank] && board.chessboard[file][rank].white? != white?
      else
        while file.between?(0,7) && rank.between?(0,7) && board.chessboard[file][rank].nil?
          file += direction[0]
          rank += direction[1]
        end
        next unless file.between?(0,7) && rank.between?(0,7) && board.chessboard[file][rank] && board.chessboard[file][rank].white? != white?
        captures << [file, rank]
      end
    end
    captures
  end
end
