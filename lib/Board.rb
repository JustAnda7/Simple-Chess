# frozen_string_literal: true

require_relative 'color'
require_relative 'Knight'
require_relative 'Rook'
require_relative 'Bishop'
require_relative 'Queen'
require_relative 'King'
require_relative 'Pawn'
require_relative 'EscapeSequences'

class Board
  include EscapeSequences
  attr_reader :chessboard, :moves, :move_no, :white_play, :old_locations, :captured_pieces, :flip, :moved_stack
  attr_accessor :score, :error_message, :remainder

  def initialize
    @chessboard = []
    @moves = []
    @move_no = 0
    @white_play = true
    @old_locations = []
    @captured_pieces = []
    @flip = []
    @moved_stack = []
    8.times { |i| @chessboard[i] = [] }
    fill_chessboard
    set_moves_and_captures
  end

  def each_piece
    chessboard.each do |rank|
      rank.each do |square|
        square ? (yield square) : next
      end
    end
  end

  def fill_chessboard
    chessboard[0][0] = WhiteRook.new(self, [0,0])
    chessboard[7][0] = WhiteRook.new(self, [7,0])
    chessboard[1][0] = WhiteKnight.new(self, [1,0])
    chessboard[6][0] = WhiteKnight.new(self, [6,0])
    chessboard[2][0] = WhiteBishop.new(self, [2,0])
    chessboard[5][0] = WhiteBishop.new(self, [5,0])
    chessboard[3][0] = WhiteQueen.new(self, [3,0])
    chessboard[4][0] = WhiteKing.new(self, [4,0])
    8.times { |i| chessboard[i][1] = WhitePawn.new(self, [i,1]) }
    chessboard[0][7] = BlackRook.new(self, [0,7])
    chessboard[7][7] = BlackRook.new(self, [7,7])
    chessboard[1][7] = BlackKnight.new(self, [1,7])
    chessboard[6][7] = BlackKnight.new(self, [6,7])
    chessboard[2][7] = BlackBishop.new(self, [2,7])
    chessboard[5][7] = BlackBishop.new(self, [5,7])
    chessboard[3][7] = BlackQueen.new(self, [3,7])
    chessboard[4][7] = BlackKing.new(self, [4,7])
    8.times { |i| chessboard[i][6] = BlackPawn.new(self, [i,6]) }
  end

  def set_moves_and_captures
    each_piece do |piece|
      piece.possible_move
      piece.possible_capture
    end
  end

  def validate_input(input)
    return false unless input.match?(/[a-h][1-8]|O-O|O-O-O/)
    input.each_char { |char| return false unless char.match?(/[a-h]|[1-8]|[KQRBNOx\-=\+#]/) }
  end

  def no_moves?
    not_avail = true
    each_piece do |piece|
      next unless piece.white? == white_play

      piece.valid_moves.each do |move|
        test_move(piece, move)
        if safe_king?
          not_avail = false
        end
        undo_test_move(piece, move)
      end
      piece.valid_captures.each do |cap|
        test_move(piece, cap)
        if safe_king?
          not_avail = false
        end
        undo_test_move(piece, cap)
      end
      if piece.is_a?(Pawn) && piece.en_passant
        test_move(piece)
        if safe_king?
          not_avail = false
        end
        undo_test_move(piece)
      end
    end
    not_avail
  end

  def move(input)
    return false unless validate_input(input)

    if input.slice!('O-O')
      kingside_castle(input)
    elsif input.slice!('O-O-O')
      queenside_castle(input)
    else
      notation = input.clone
      played_piece = find_played_piece(notation.slice!(/[KQRBN]/))
      played_move = to_coordinates(notation.slice!(/[a-h][1-8]/))
      action = notation.slice!('x') ? 'capture' : 'move'

      if [WhitePawn, BlackPawn].include?(played_piece)
        piece = find_pawn(played_piece, played_move, action, notation, input)
        return piece if [true, false].include?(piece)
        piece = promote(piece, notation.slice!(0,2)) if [0,7].include?(played_move[1])
      else
        piece = find_piece(played_piece, played_move, action, notation, input)
      end
      return false unless piece

      test_move(piece, played_move)
      unless validate_move && check_remaining(input, notation)
        undo_test_move(piece, played_move)
        return false
      end
      undo_test_move(piece, played_move)
      enter_valid_move(piece, played_move, input)
    end
  end

  def enter_valid_move(played_piece, played_move, input)
    chessboard[played_piece.position[0]][played_piece.position[1]] = nil
    chessboard[played_move[0]][played_move[1]] = played_piece
    add_en_passant(played_piece, played_move)
    played_piece.position = played_move
    update_move_list(input)
    played_piece.has_moved if played_piece.respond_to?(:has_moved)
    # irreversible = piece.is_a?(Pawn) || input.include?('x')
    finalize_move
  end

  def finalize_move
    # parameters for 50 move rule and threefold repetition; #castle doesn't provide argument
    clear_en_passant
    @white_play = white_play ? false : true
    # update_repetitions(irreversible, altered_state)
    set_moves_and_captures
    true
  end

  def update_move_list(input)
    if white_play
      @move_no += 1
      @moves << +"#{move_no}. #{' ' if move_no < 10}#{input}"
    else
      justify_left = 12 - moves.last.length
      justify_right = 8 - input.length
      @moves.last << "#{' ' * justify_left}#{input}#{' ' * justify_right}"
    end
  end

  def print_line(i, k, rank = nil)
    print '  ' unless rank
    8.times do |j|
      m = flip ? 7 - j : j
      piece = chessboard[m][rank] if rank
      if (i + j).even?
        print "   #{piece || ' '}".bg_black + "   ".bg_black
      else
        print "   #{piece || ' '}".bg_gray + "   ".bg_gray
      end
    end
    display_moves(i * 3 + k)
    puts
  end

  def display_moves(line)
    print " #{moves[line]}" if move_no > line
    print "| #{moves[line + 24]}" if move_no > line + 24
    print "| #{moves[line + 48]}" if move_no > line + 48
    print "| #{moves[line + 72]}" if move_no > line + 72
    print "| #{moves[line + 96]}" if move_no > line + 96
    print "| #{moves[line + 120]}" if move_no > line + 120
    print "| #{moves[line + 144]}" if move_no > line + 144
  end

  def display(num = 28)
    move_up(num)
    8.times do |i|
      m = flip ? i : 7 - i
      print_line(i, 0)
      print "#{m + 1} "
      print_line(i, 1, m)
      print_line(i, 2)
    end
    8.times do |i|
      m = flip ? 7 - i : i
      print "     #{(m + 97).chr} "
    end
    puts
    puts_clear
    puts
  end

  def flip_board(show_display = true)
    @flip = flip ? false : true
    display if show_display
  end

  def over?
    @score =
      if checkmate?
        white_play ? '0-1 Black Wins' : '1-0 White Wins'
      elsif stalemate?
        '1/2 - 1/2 Stalemate'
      elsif no_mating_material?
        '1/2 - 1/2 Insufficient Mating Material'
      # elsif fifty_moves?
      #   '1/2 - 1/2 Fifty Move Rule'
      # elsif threefold_repetition?
      #   '1/2 - 1/2 Draw by Threefold Repetition'
      end
    return score ? true : false
  end

  def find_played_piece(string)
    case string
    when 'K' then white_play ? WhiteKing : BlackKing
    when 'Q' then white_play ? WhiteQueen : BlackQueen
    when 'R' then white_play ? WhiteRook : BlackRook
    when 'B' then white_play ? WhiteBishop : BlackBishop
    when 'N' then white_play ? WhiteKnight : BlackKnight
    else white_play ? WhitePawn : BlackPawn
    end
  end

  def in_check?
    target = white_play ? WhiteKing : BlackKing
    each_piece do |piece|
      next if piece.white? == white_play

      piece.valid_captures.each { |c| return true if chessboard[c[0]][c[1]].is_a? target }
    end
    false
  end

  def checkmate?
    (no_moves? && in_check?) ? true : false
  end

  def stalemate?
    (no_moves? && safe_king?) ? true : false
  end

  def no_mating_material?
    pieces_left = []
    each_piece do |piece|
      return false if piece.is_a?(Pawn) || piece.is_a?(Rook) || piece.is_a?(Queen)
      next if piece.is_a?(King)

      pieces_left << piece
    end
    return true if pieces_left.length < 2 || pieces_left.length == 2 && pieces_left[0].is_a?(Bishop) && pieces_left[1].is_a?(Bishop) # check for any other condition
  end

  def to_coordinates(move)
    [(move[0].ord - 97), (move[1].to_i - 1)]
  end

  def find_pawn(played_piece, played_move, action, notation, input)
    if action == 'capture'
      file = find_pawn_file(notation.slice!(0))
      return false unless file
    end
    each_piece do |piece|
      next unless piece.is_a?(played_piece)

      return piece if action == 'move' && piece.valid_moves.include?(played_move)

      if action == 'capture'
        return piece if piece.valid_captures.include?(played_move)
        return en_passant(piece, input, notation) if piece.en_passant == played_move
      end
    end
    @error_message = case action
                      when 'move' then 'Move Unavailable'
                      when 'capture' then 'Capture Unavailable'
                      end
    false
  end

  def find_pawn_file(char)
    if char.match?(/[a-h]/)
      char.ord - 97
    else
      @error_message = "Invalid Pawn move"
    end
  end

  def find_piece(played_piece, played_move, action, notation, input)
    candidates = []
    each_piece do |piece|
      next unless piece.is_a? played_piece

      if action == 'move'
        candidates << piece if piece.valid_moves.include?(played_move)
      elsif action == 'capture'
        candidates << piece if piece.valid_captures.include?(played_move)
      end
    end
    if candidates.length == 0
      @error_message = case action
                        when 'move' then 'No move'
                        when 'capture' then 'No capture'
                        end
      false
    elsif candidates.length == 1
      candidates.first
    else
      disambiguation(candidates, played_piece, played_move)
    end
  end

  def disambiguation(candidates, played_piece, notation)
    final = filter_by_legality(candidates, played_piece)
    return final.first if final.length == 1

    final = filter_by_location(candidates, played_move.slice!(0))
    return final.first if final.length == 1
  end

  def filter_by_legality(candidates, played_piece)
    candidates.reject do |piece|
      test_move(piece, played_move)
      illegal = in_check?
      undo_test_move(piece, played_move)
      illegal
    end
  end

  def filter_by_location(candidates, selection)
    final = []
    if selection&.match?(/[a-h]/)
      candidates.each { |c| final << c if c.position[0] == (selection.ord - 97) }
    elsif selection&.match?(/[1-8]/)
      candidates.each { |c| final << c if c.position[1] == (selection.to_i - 1) }
    end
    final
  end

  def kingside_castle(notation)
    rank = white_play ? 0 : 7
    target = [[4, rank], [7, rank]]
    empty_sq = [[5, rank], [6, rank]]
    return false unless validate_castle(target, empty_sq, 'king')

    castle(empty_sq[1], target[0], empty_sq[0], target[1], +'0-0', notation)
  end

  def queenside_castle(notation)
    rank = white_play ? 0 : 7
    target = [[4, rank], [0, rank]]
    empty_sq = [[3, rank], [2, rank], [1, rank]]
    return false unless validate_castle(target, empty_sq, 'queen')

    castle(empty_sq[1], target[0], empty_sq[0], target[1], +'0-0-0', notation)
  end

  def validate_castle(target, empty_sq, type)
    return false if in_check?

    target.each do |t|
      return false unless ((chessboard[t[0]][t[1]].is_a?(Rook) || chessboard[t[0]][t[1]].is_a?(King)) && !chessboard[t[0]][t[1]].has_moved?)
    end

    empty_sq.each { |e| return false unless chessboard[e[0]][e[1]].nil? }
    each_piece do |piece|
      next if white_play == piece.white?
      return false unless (piece.valid_moves & empty_sq).empty?
    end
    true
  end

  def test_castle(nking, oking, nrook, orook)
    chessboard[nking[0]][nking[1]] = chessboard[oking[0]][oking[1]]
    chessboard[oking[0]][oking[1]] = nil
    chessboard[nrook[0]][nrook[1]] = chessboard[orook[0]][orook[1]]
    chessboard[orook[0]][orook[1]] = nil
    chessboard[nking[0]][nking[1]].position = nking
    chessboard[nrook[0]][nrook[1]].position = nrook
    set_moves_and_captures
  end

  def undo_test_castle(nking, oking, nrook, orook)
    chessboard[oking[0]][oking[1]] = chessboard[nking[0]][nking[1]]
    chessboard[nking[0]][nking[1]] = nil
    chessboard[orook[0]][orook[1]] = chessboard[nrook[0]][nrook[1]]
    chessboard[nrook[0]][nrook[1]] = nil
    chessboard[oking[0]][oking[1]].position = oking
    chessboard[orook[0]][orook[1]].position = orook
    set_moves_and_captures
  end

  def castle(nking, oking, nrook, orook, input, notation)
    test_castle(nking, oking, nrook, orook)
    unless check_remaining(input, notation)
      undo_test_castle(nking, oking, nrook, orook)
      return false
    end
    update_move_list(input)
    chessboard[nking[0]][nking[1]].has_moved
    chessboard[nrook[0]][nrook[1]].has_moved
    finalize_move
    true
  end

  def en_passant(piece, input, notation)
    return false unless validate_en_passant(piece, input, notation)

    chessboard[piece.position[0]][piece.position[1]] = nil
    chessboard[piece.en_passant[0]][piece.en_passant[1]] = piece
    chessboard[piece.en_passant_capture[0]][piece.en_passant_capture[1]] = nil
    piece.position = piece.en_passant
    update_move_list(input)
    finalize_move
    true
  end

  def add_en_passant(played_piece, played_move)
    return unless played_piece.is_a?(Pawn) && (played_move[1] - played_piece.position[1]).abs == 2

    target = white_play ? BlackPawn : WhitePawn
    file = played_move[0]
    rank = played_move[1]
    if file.positive?
      adj = chessboard[file - 1][rank]
      adj.add_en_passant(file) if adj&.is_a?(target)
    end
    if file < 7
      adj = chessboard[file + 1][rank]
      adj.add_en_passant(file) if adj&.is_a?(target)
    end
  end

  def clear_en_passant
    each_piece do |piece|
      next unless piece.is_a?(Pawn) && piece.white? == white_play
      piece.remove_en_passant
    end
  end

  def validate_en_passant(piece, input, notation)
    test_move(piece)
    unless validate_move && check_remaining(input, notation)
      undo_test_move(piece)
      return false
    end
    undo_test_move(piece)
    true
  end

  def test_move(piece, move = nil)
    chessboard[piece.position[0]][piece.position[1]] = nil
    old_locations << piece.position
    if move
      captured_pieces << chessboard[move[0]][move[1]]
      chessboard[move[0]][move[1]] = piece
      piece.position = move
    else
      chessboard[piece.en_passant[0]][piece.en_passant[1]] = piece
      captured_pieces << chessboard[piece.en_passant_capture[0]][piece.en_passant_capture[1]]
      chessboard[piece.en_passant_capture[0]][piece.en_passant_capture[1]] = nil
      piece.position = piece.en_passant
    end
    set_moves_and_captures
  end

  def undo_test_move(piece, move = nil)
    prev_move = old_locations.pop
    captured_piece = captured_pieces.pop
    chessboard[prev_move[0]][prev_move[1]] = piece
    if move
      chessboard[move[0]][move[1]] = captured_piece
    else
      chessboard[piece.en_passant[0]][piece.en_passant[1]] = nil
      chessboard[piece.en_passant_capture[0]][piece.en_passant_capture[1]] = captured_piece
    end
    piece.position = prev_move
    set_moves_and_captures
  end

  def check_remaining(input, notation)
    set_remaining
    if remainder.include?(notation)
      input << remainder.first unless remainder.first == notation
      true
    else
      @error_message = "Extra chars in input move"
      false
    end
  end

  def set_remaining
    @white_play = @white_play ? false : true
    @remainder = if checkmate?
                   ['#', '']
                 elsif in_check?
                   ['+', '']
                 else
                   ['']
                 end
    @white_play = @white_play ? false : true
  end

  def validate_move
    unless safe_king?
      @error_message = "King In Check"
      return false
    end
    true
  end

  def safe_king?
    !in_check?
  end

  def promote(piece, notation)
    @error_message = "Invalid Promotion"
    return false unless piece && notation[0] == '='

    case notation[1]
    when 'Q' then white_play ? WhiteQueen.new(self, piece.position) : BlackQueen.new(self, piece.position)
    when 'R' then white_play ? WhiteRook.new(self, piece.position) : BlackRook.new(self, piece.position)
    when 'B' then white_play ? WhiteBishop.new(self, piece.position) : BlackBishop.new(self, piece.position)
    when 'N' then white_play ? WhiteKnight.new(self, piece.position) : BlackKnight.new(self, piece.position)
    else false
    end
  end
end
