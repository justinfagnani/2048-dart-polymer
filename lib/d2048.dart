library d2048;

import 'dart:async';
import 'dart:html';
import 'dart:math' show Random, max, min;
import 'package:polymer/polymer.dart';
import 'grid.dart';

@CustomTag('d2048-game')
class Game extends PolymerElement {
  final _random = new Random();
  final int _size = 4;
  final _transitionDuration = new Duration(milliseconds: 180);

  Grid _grid;

  @observable int score = 0;
  @observable bool gameOver = false;
  @observable bool gameWon = false;
  bool _moving = false;

  final ticks = [0, 1, 2, 3];

  Game.created() : super.created() {
    window.onKeyDown
        .map((e) => e.keyCode - 37)
        .where((k) => k >= 0 && k <= 3 &&
            gameOver == false && _moving == false)
        .listen(move);
  }

  start() {
    _grid = new Grid(_size);
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
      if (_grid.getCell(0, row, col) == null) {
        var value = _random.nextDouble() < 0.9 ? 2 : 4;
        var tile = _grid.setCell(0, row, col, new Tile(value));
        tiles.children.add(tile);
        tile.setPosition(row, col);
        break;
      }
    }
    if (tiles.children.length == _size * _size) {
      gameOver = isGameOver();
    }
  }

  move(int dir) {
    bool moved = false;
    for (int i = 0; i < _size; i++) {
      int spacesToMove = 0;
      Tile previousTile = null;
      for (int j = 0; j < _size; j++) {
        var tile = _grid.getCell(dir, i, j);
        if (tile == null) {
          spacesToMove++;
        } else {
          bool merge = previousTile != null && previousTile.value == tile.value;
          if (merge) {
            spacesToMove++;
            previousTile.style.setProperty('z-index', '100');
          }
          if (spacesToMove > 0) {
            assert(_grid.getCell(dir, i, j) == tile);
            int newJ = j - spacesToMove;
            _grid.setCell(dir, i, j, null);
            _grid.setCell(dir, i, newJ, tile);
            tile.setPosition(
                _grid.getRow(dir, i, newJ),
                _grid.getCol(dir, i, newJ));
            moved = true;
            _moving = true;
          }
          if (merge) {
            var mergedTile = previousTile;
            tile.onTransitionEnd.first.then((_) {
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
      $['tiles'].onTransitionEnd.first.then((_) {
        new Future(() { // wait for merged tiles to be removed
          newTile();
          _moving = false;
        });
      });
    }
  }

  isGameOver() {
    for (int i = 0; i < _size - 1; i++) {
      for (int j = 0; j < _size - 1; j++) {
        var tile = _grid.getCell(0, i, j);
        if (tile == null) return false;
        var value = tile.value;
        var neighbor = _grid.getCell(0, i+1, j);
        if (neighbor == null || neighbor.value == value) return false;
        neighbor = _grid.getCell(0, i, j+1);
        if (neighbor == null || neighbor.value == value) return false;
      }
    }
    return true;
  }
}

@CustomTag('d2048-tile')
class Tile extends PolymerElement with Observable {
  @published @PublishedProperty(reflect: true) int value;

  Tile.created() : super.created();

  factory Tile(value) => (new Element.tag('d2048-tile') as Tile)
      ..value = value;

  setPosition(row, col) {
    style.setProperty('-webkit-transform',
        'translate(${19 + col * 127}px, ${19 + row * 130}px)');
  }

}
