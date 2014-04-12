library d2048;

import 'dart:async';
import 'dart:html';
import 'dart:math' show Random;
import 'package:polymer/polymer.dart';

@CustomTag('d2048-game')
class Game extends PolymerElement {
  final _random = new Random();
  final int _size = 4;
  final _transitionDuration = new Duration(milliseconds: 100);

  List<List<Tile>> _grid;
  @observable int score = 0;
  @observable bool gameOver = false;
  @observable bool gameWon = false;

  final ticks = [0, 1, 2, 3];

  Game.created() : super.created() {
    window.onKeyDown
        .map((e) => e.keyCode - 37)
        .where((k) => k >= 0 && k <= 3 && gameOver == false)
        .listen(move);
  }

  start() {
    _grid = new List.generate(_size, (i) => new List(_size));
    $['tiles'].children.clear();
    score = 0;
    gameOver = false;
    gameWon = false;
    newTile();
    newTile();
  }

  newTile() {
    var tiles = $['tiles'];
    assert(tiles.children.length < _size * _size);
    while (true) {
      int row = _random.nextInt(_size);
      int col = _random.nextInt(_size);
      if (_grid[row][col] == null) {
        var value = _random.nextDouble() < 0.9 ? 2 : 4;
        var tile = _grid[row][col] = new Tile(value);
        tiles.children.add(tile);
        _setTransform(tile, row, col);
        break;
      }
    }
    if (tiles.children.length == _size * _size) {
      gameOver = true;
    }
  }

  move(int dir) {
    bool moved = false;
    for (int i = 0; i < _size; i++) {
      int spacesToMove = 0;
      Tile previousTile = null;
      for (int j = 0; j < _size; j++) {
        var tile = _getTile(dir, i, j);
        if (tile == null) {
          spacesToMove++;
        } else {
          bool merge = false;
          if (previousTile != null && previousTile.value == tile.value) {
            merge = true;
            spacesToMove++;
          }
          if (spacesToMove > 0) {
            _moveTile(dir, tile, i, j, spacesToMove);
            moved = true;
          }
          if (merge) {
            var mergedTile = previousTile;
            new Timer(_transitionDuration, () {
              tile.value *= 2;
              score += tile.value;
              mergedTile.remove();
              if (tile.value == 2048) {
                gameWon = true;
              }
            });
            previousTile = null;
          } else {
            previousTile = tile;
          }
        }
      }
    }
    if (moved) {
      new Timer(_transitionDuration, () {
        newTile();
      });
    }
  }

  Tile _getTile(d, i, j) => _grid[_getRow(d, i, j)][_getCol(d, i, j)];

  int _getRow(d, i, j) => (d == 0) ? i : (d == 1) ? j :
    (d == 2) ? _size - i - 1 : _size - j - 1;

  int _getCol(d, i, j) => (d == 0) ? j : (d == 1) ? i :
    (d == 2) ? _size - j - 1 : _size - i - 1;

  _moveTile(d, tile, i, j, spaces) {
    int row = _getRow(d, i, j);
    int col = _getCol(d, i, j);
    assert(_grid[row][col] == tile);
    _grid[row][col] = null;
    switch (d) {
      case 0: col -= spaces; break;
      case 1: row -= spaces; break;
      case 2: col += spaces; break;
      case 3: row += spaces; break;
    }
    _grid[row][col] = tile;
    _setTransform(tile, row, col);
  }

  _setTransform(tile, row, col) {
    tile.style.setProperty('-webkit-transform',
        'translate(${19 + col * 127}px, ${19 + row * 130}px)');
  }

}

@CustomTag('d2048-tile')
class Tile extends PolymerElement with Observable {
  int _value;

  Tile.created() : super.created();

  factory Tile(value) => (new Element.tag('d2048-tile') as Tile)
      ..value = value;

  @observable int get value => _value;
  set value(v) {
    // It'd be nice if this could be declared as a data-bound attribute on
    // the element declaration like: <polymer-element class="tile-{{value}}">
    classes.remove('tile-$_value');
    _value = notifyPropertyChange(#value, _value, v);
    classes.add('tile-$_value');
  }
}
