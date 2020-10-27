import 'package:flutter/cupertino.dart';

class Recognition {
  String _label;
  double _score;
  Rect _location;

  Recognition(this._label, this._score, [this._location]);

  String get label => _label;
  double get score => _score;
  Rect get location => _location;

  @override
  String toString() {
    return 'Recognition(label: $label, score: $score, location: $location)';
  }
}
