# CHESS

Command Line Chess written in Ruby

---------

[Standard Algebraic Notation](https://en.wikipedia.org/wiki/Algebraic_notation_(chess)) with [PGN](https://en.wikipedia.org/wiki/Portable_Game_Notation) standards is used for both display and input. A few clarifying notes regarding input:

- O-O and O-O-O are used for castling (the letter, not zero)
- En passant capture is entered as if capturing a pawn that had only moved 1 square (no e.p. at end)
- Disambiguation is required if more than one of the specified piece can move to the target square (e.g. Nbd2 to specify that the Knight on the b-file is meant to move to d2; R1e1 to specify that the Rook on  the 1st rank is meant to move to e1)
- Promote a pawn to a Queen, Rook, Bishop, or Knight by appending to the move =Q, =R, =B, or =N, respectively

User can enter any of the following commands instead of a move:

- **help** - show commands
- **flip** - flip board
- **draw** - offer opponent a draw(Mostly bluffing that you can win)
- **resign** - Option for people embaressed to Lose
- **quit** - Self explainatory I guess
- **instructions** - displays instructions for immediate referal
- **tutorial** - shows instructions and examples on inputting moves(Baby Steps)

A note on display: the pieces are tragically small, but can get a bit larger depending on the font in terminal.

## How to Run the Game
- Clone the repository to a location using `git clone`.
- Navigate to the `lib` directory.
- Run the game using `ruby Main.rb`
- Enjoy!!
