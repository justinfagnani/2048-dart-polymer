library d2048.grid;

class Grid<T> {
  final int size;
  List<List<T>> _cells;

  Grid(int size)
    : size = size,
      _cells = new List.generate(size, (i) => new List(size));

  List<List<T>> get cells => _cells;

  /**
   * Returns the value of a cell at the coordinate ([i], [j]) after applying a
   * rotation [d], where d is the number of turns clockwise.
   */
  T getCell(int dir, int i, int j) =>
      _cells[getRow(dir, i, j)][getCol(dir, i, j)];

  T setCell(int dir, int i, int j, T v) =>
      _cells[getRow(dir, i, j)][getCol(dir, i, j)] = v;

  int getRow(d, i, j) => (d == 0) ? i : (d == 1) ? j :
    (d == 2) ? size - i - 1 : size - j - 1;

  int getCol(d, i, j) => (d == 0) ? j : (d == 1) ? i :
    (d == 2) ? size - j - 1 : size - i - 1;

}
