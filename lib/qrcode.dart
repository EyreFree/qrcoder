import 'dart:convert';
import 'dart:core';

import 'qrcode_model.dart';
import 'qrcode_type.dart';
import 'qr_error_correct_level.dart';

class QRCode {
  /// Content.
  String text;

  /// Error correct level.
  QRErrorCorrectLevel correctLevel;

  /// If the image codes has a border around its content.
  bool hasBorder;
  int typeNumber;

  QRCodeModel _model;

  /// Construct a QRCode instance.
  ///
  /// - Parameters:
  ///   - text: content of the QRCode.
  ///   - encoding: encoding used for generating data from text.
  ///   - errorCorrectLevel: error correct level, defaults to high.
  ///   - hasBorder: if the image codes has a border around, defaults and suggests to be true.
  ///
  /// - Warning: Is computationally intensive.
  QRCode(String text,
      {Encoding encoding = utf8,
      QRErrorCorrectLevel errorCorrectLevel = QRErrorCorrectLevel.H,
      bool hasBorder = true}) {
    int typeNumber = QRCodeTypeExtension.typeNumberOf(text, errorCorrectLevel);
    QRCodeModel model =
        QRCodeModel(text, typeNumber, errorCorrectLevel, encoding: encoding);
    this.typeNumber = typeNumber;
    this._model = model;
    this.text = text;
    this.correctLevel = errorCorrectLevel;
    this.hasBorder = hasBorder;
  }

  /// QRCode in binary form.
  List<List<int>> imageCodes() {
    List<List<int>> ans = [];
    if (hasBorder) {
      List<int> borderLine =
          List<int>.filled(_model.moduleCount + 2, 0, growable: false);
      ans.add(borderLine);
      for (int r = 0; r < _model.moduleCount; r++) {
        List<int> line = [0];
        for (int c = 0; c < _model.moduleCount; c++) {
          line.add(_model.isDark(r, c) ? 1 : 0);
        }
        line.add(0);
        ans.add(line);
      }
      ans.add(borderLine);
    } else {
      for (int r = 0; r < _model.moduleCount; r++) {
        List<int> line = [];
        for (int c = 0; c < _model.moduleCount; c++) {
          line.add(_model.isDark(r, c) ? 1 : 0);
        }
        ans.add(line);
      }
    }
    return ans;
  }

  /// Convert QRCode to String.
  ///
  /// - Parameters:
  ///   - black: recommend to be "\u{1B}[7m  " or "##".
  ///   - white: recommend to be "\u{1B}[0m  " or "  ".
  /// - Returns: a matrix of characters that is scannable.
  String toStringFilledAndPatchedWith(
      {String black = '⬛️', String white = '⬜️'}) {
    String result = '';
    final List<List<int>> imageCodes = this.imageCodes();
    for (var imageLine in imageCodes) {
      String line = '';
      for (var imageCode in imageLine) {
        line += (imageCode == 0 ? white : black);
      }
      result += (line + '\n');
    }
    return result;
  }
}
