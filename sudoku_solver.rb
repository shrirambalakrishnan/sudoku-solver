class SolveSudoku
  def initialize( board )
    @board = board

    # We will have two instance variables.
    # 1. '@can_change_position' - Whether a number is entered by user as input. This is needed because during
    # backtracking the cell should be skipped.
    # 2. '@available_position_choices' - Contains a hash consisting of 1 to 9 keys with initial value true.
    # When a value can no longer be entered in a cell, the value for the key will become false.
    @can_change_position = Array.new(9) { Array.new(9) }
    @available_position_choices = Array.new(9) { Array.new(9) { Hash.new } }

    # Initialize the arrays.
    (0...9).each do |row|
      (0...9).each do |col|
        @can_change_position[row][col] = @board[row][col].nil?

        (1..9).each do |choice|
          @available_position_choices[row][col][choice] = true
        end
      end
    end
  end

  # Solving by backtracking.
  def solve
    row = 0

    while row < 9
      col = 0

      while col < 9
        col += 1 and next unless can_change_position?( row, col )

        suggested_number = get_choice( row, col )

        # If 'suggested_number' is a Integer, then a valid choice is present. Assign the choice to the position.
        # Else, if false gets returned, then no valid choice is present.
        # In this case, get back to the previous cell and recalculate the the value for it.
        if suggested_number.is_a?( Integer )
          @board[row][col] = suggested_number
          col += 1

        elsif suggested_number.is_a?( FalseClass )
          new_row, new_col = get_previous_position( row, col )

          # Also set the current position's @available_position_choices hash to true.
          @board[row][col] = nil
          @available_position_choices[row][col].each do |num, val|
            @available_position_choices[row][col][num] = true
          end

          row = new_row
          col = new_col
        end
      end

      row += 1
    end

    @board
  end

  # Method to get one of the possible choices for a position.
  def get_choice( x_coord, y_coord )
    suggested_number = nil

    @available_position_choices[x_coord][y_coord].each do |number, is_available|
      next unless is_available

      if valid_choice?( x_coord, y_coord, number )
        suggested_number = number
        @available_position_choices[x_coord][y_coord][number] = false
        break
      end
    end

    suggested_number.nil? ? false : suggested_number
  end

  # If the position has number that is entered as input for problem, it should not be edited.
  # The condition is checked here.
  def can_change_position?( x_coord, y_coord )
    @can_change_position[x_coord][y_coord]
  end

  # Method to check if the number suggested for a position is valid or not.
  # It is a valid choice if,
  # 1. The number is not present in that row.
  # 2. The number is not present in that column.
  # 3. The number is not present in the 3 by 3 box.
  def valid_choice?( x_coord, y_coord, number )
    # 1
    @board[x_coord].each do |column_value|
      next if column_value.nil?
      return false if number == column_value
    end

    # 2
    (0...9).each do |row|
      next if @board[row][y_coord].nil?
      return false if number == @board[row][y_coord]
    end

    # 3
    x_offset = x_coord % 3
    y_offset = y_coord % 3
    box_start_x_coord = x_coord - x_offset
    box_end_x_coord = box_start_x_coord + 2

    box_start_y_coord = y_coord - y_offset
    box_end_y_coord = box_start_y_coord + 2

    (box_start_x_coord..box_end_x_coord).each do |row|
      (box_start_y_coord..box_end_y_coord).each do |col|
        next if @board[row][col].nil?
        return false if number == @board[row][col]
      end
    end
  end

  def get_previous_position( x_coord, y_coord )

    if y_coord > 0
      previous_x_coord = x_coord
      previous_y_coord = y_coord - 1
    else
      previous_x_coord = x_coord - 1
      previous_y_coord = 8
    end

    return [previous_x_coord, previous_y_coord] if can_change_position?( previous_x_coord, previous_y_coord )

    get_previous_position( previous_x_coord, previous_y_coord )
  end
end

# 9*9 array to get the initial board.
sudoku_puzzle = Array.new(9) { Array.new(9) }

puts '======================================================================================'
puts 'Enter the Sudoku puzzle'
puts 'Please enter \'0\' in place of blank values that needs to be solved'
puts '======================================================================================'

(0...9).each do |row|
  input_array = gets.split( ' ' ).map( &:to_i )

  return 'Enter only 9 numbers' unless 9 == input_array.size

  input_array.each_with_index do |number, index|
    return 'Enter numbers between 0 to 9' unless ( 0..9 ).include?( number )
    sudoku_puzzle[row][index] = number.nonzero? ? number : nil
  end
end

sudoku_solver = SolveSudoku.new( sudoku_puzzle )
solution = sudoku_solver.solve

puts '=========================================== Here is the solution ==========================================='

(0...9).each do |row|
  puts solution[row].map( &:to_s ).join( ' ' )
end