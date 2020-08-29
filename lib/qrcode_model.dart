import 'dart:convert' show Encoding, utf8;
import 'dart:math';

import 'package:flutter/cupertino.dart';

import 'qr_rs_block.dart';
import 'an_error.dart';
import 'qr_8bit_byte.dart';
import 'qr_bit_buffer.dart';
import 'qr_error_correct_level.dart';
import 'qr_mask_pattern.dart';
import 'qr_pattern_locator.dart';
import 'bch_util.dart';
import 'qr_polynomial.dart';
import 'qr_mode.dart';
import 'int_extension.dart';

class QRCodeModel {
  int typeNumber;
  QRErrorCorrectLevel errorCorrectLevel;

  /// -1: null, 0: false, 1: true
  List<List<int>> _modules = [];
  int moduleCount = 0;
  QR8bitByte _encodedText;
  List<int> _dataCache = [];

  QRCodeModel(
      String text, int typeNumber, QRErrorCorrectLevel errorCorrectLevel,
      {Encoding encoding = utf8}) {
    _encodedText = QR8bitByte(text, encoding: encoding);
    this.typeNumber = typeNumber;
    this.errorCorrectLevel = errorCorrectLevel;
    _dataCache =
        QRCodeModel._createData(typeNumber, errorCorrectLevel, _encodedText);

    _makeImplIsTest(false, _getBestMaskPattern());
  }

  /// Please be aware of index out of bounds error yourself.
  bool isDark(int row, int col) {
    return _modules[row][col] == 1;
  }

  bool isLight(int row, int col) {
    return !isDark(row, col);
  }

  void _makeImplIsTest(bool test, QRMaskPattern maskPattern) {
    moduleCount = typeNumber * 4 + 17;
    _modules = List<List<int>>.filled(moduleCount, [], growable: false);
    for (int i = 0; i < moduleCount; i++) {
      _modules[i] = List<int>.filled(moduleCount, -1, growable: false);
    }
    _setupPositionProbePattern(0, 0);
    _setupPositionProbePattern(moduleCount - 7, 0);
    _setupPositionProbePattern(0, moduleCount - 7);
    _setupPositionAdjustPattern();
    _setupTimingPattern();
    _setupTypeInfoIsTest(test, maskPattern.rawValue);
    if (typeNumber >= 7) {
      _setupTypeNumberIsTest(test);
    }
    _mapData(_dataCache, maskPattern);
  }

  void _setupPositionProbePattern(int row, int col) {
    for (int r = -1; r <= 7; r++) {
      if ((row + r <= -1) || (moduleCount <= row + r)) {
        continue;
      }
      for (int c = -1; c <= 7; c++) {
        if ((col + c <= -1) || (moduleCount <= col + c)) {
          continue;
        }
        if ((0 <= r && r <= 6 && (c == 0 || c == 6)) ||
            (0 <= c && c <= 6 && (r == 0 || r == 6)) ||
            (2 <= r && r <= 4 && 2 <= c && c <= 4)) {
          _modules[row + r][col + c] = 1;
        } else {
          _modules[row + r][col + c] = 0;
        }
      }
    }
  }

  void _setupTimingPattern() {
    for (int i = 8; i < moduleCount - 8; i++) {
      if (_modules[i][6] == -1) {
        _modules[i][6] = ((i % 2 == 0) ? 1 : 0);
      }
      if (_modules[6][i] == -1) {
        _modules[6][i] = ((i % 2 == 0) ? 1 : 0);
      }
    }
  }

  void _setupPositionAdjustPattern() {
    List<int> pos = QRPatternLocator.getPatternPositionOfType(typeNumber);
    for (int i = 0; i < pos.length; i++) {
      for (int j = 0; j < pos.length; j++) {
        int row = pos[i];
        int col = pos[j];
        if (_modules[row][col] != -1) {
          continue;
        }
        for (int r = -2; r <= 2; r++) {
          for (int c = -2; c <= 2; c++) {
            if (r == -2 || r == 2 || c == -2 || c == 2 || r == 0 && c == 0) {
              _modules[row + r][col + c] = 1;
            } else {
              _modules[row + r][col + c] = 0;
            }
          }
        }
      }
    }
  }

  void _setupTypeNumberIsTest(bool test) {
    int bits = BCHUtil.bchTypeNumberOf(typeNumber);
    for (int i = 0; i < 18; i++) {
      int mod = (!test && ((bits >> i) & 1) == 1) ? 1 : 0;
      _modules[i ~/ 3][i % 3 + moduleCount - 8 - 3] = mod;
      _modules[i % 3 + moduleCount - 8 - 3][i ~/ 3] = mod;
    }
  }

  void _setupTypeInfoIsTest(bool test, int maskPattern) {
    int data = (errorCorrectLevel.rawValue << 3) | maskPattern;
    int bits = BCHUtil.bchTypeInfoOf(data); // To enforce signed shift
    for (int i = 0; i < 15; i++) {
      int mod = !test && ((bits >> i) & 1) == 1 ? 1 : 0;

      if (i < 6) {
        _modules[i][8] = mod;
      } else if (i < 8) {
        _modules[i + 1][8] = mod;
      } else {
        _modules[moduleCount - 15 + i][8] = mod;
      }

      if (i < 8) {
        _modules[8][moduleCount - i - 1] = mod;
      } else if (i < 9) {
        _modules[8][15 - i - 1 + 1] = mod;
      } else {
        _modules[8][15 - i - 1] = mod;
      }
    }
    _modules[moduleCount - 8][8] = !test ? 1 : 0;
  }

  void _mapData(List<int> data, QRMaskPattern maskPattern) {
    int inc = -1;
    int row = moduleCount - 1;
    int bitIndex = 7;
    int byteIndex = 0;

    for (int col = moduleCount - 1; col > 0; col -= 2) {
      if (col == 6) {
        col -= 1;
      }
      while (true) {
        for (int c = 0; c < 2; c++) {
          if (_modules[row][col - c] == -1) {
            bool dark = false;
            if (byteIndex < data.length) {
              int elem = data[byteIndex];
              dark = (elem.zeroFillRightShift(bitIndex) & 1) == 1;
            }
            bool mask = maskPattern.getMask(row, col - c);
            if (mask == true) {
              dark = !dark;
            }
            _modules[row][col - c] = dark ? 1 : 0;
            bitIndex -= 1;
            if (bitIndex == -1) {
              byteIndex += 1;
              bitIndex = 7;
            }
          }
        }
        row += inc;
        if (row < 0 || moduleCount <= row) {
          row -= inc;
          inc = -inc;
          break;
        }
      }
    }
  }

// UInt
  static int _PAD0 = 0xEC;

// UInt
  static int _PAD1 = 0x11;

  static List<int> _createData(
      int typeNumber, QRErrorCorrectLevel errorCorrectLevel, QR8bitByte data) {
    List<QRRSBlock> rsBlocks = errorCorrectLevel.getRSBlocksOfType(typeNumber);
    QRBitBuffer buffer = QRBitBuffer();

    buffer.put(data.mode.rawValue, 4);
    int length = data.mode.bitCountOfType(typeNumber);
    buffer.put(data.count, length);
    data.writeTo(buffer);

    int totalDataCount = 0;
    for (int i = 0; i < rsBlocks.length; i++) {
      totalDataCount += rsBlocks[i].dataCount;
    }
    if (buffer.bitCount > totalDataCount * 8) {
      throw AnError(
          "code length overflow. (\(buffer.bitCount)>\(totalDataCount * 8))");
    }
    if (buffer.bitCount + 4 <= totalDataCount * 8) {
      buffer.put(0, 4);
    }
    while (buffer.bitCount % 8 != 0) {
      buffer.putBit(false);
    }
    while (true) {
      if (buffer.bitCount >= totalDataCount * 8) {
        break;
      }
      buffer.put(QRCodeModel._PAD0, 8);
      if (buffer.bitCount >= totalDataCount * 8) {
        break;
      }
      buffer.put(QRCodeModel._PAD1, 8);
    }
    List<int> bytes = QRCodeModel._createBytesFromBuffer(buffer, rsBlocks);
    return bytes;
  }

  static List<int> _createBytesFromBuffer(
      QRBitBuffer buffer, List<QRRSBlock> rsBlocks) {
    int offset = 0;
    int maxDcCount = 0;
    int maxEcCount = 0;
// Actual contents will be assigned later
    List<List<int>> dcdata =
        List<List<int>>.filled(rsBlocks.length, [], growable: false);
    List<List<int>> ecdata =
        List<List<int>>.filled(rsBlocks.length, [], growable: false);
    for (int r = 0; r < rsBlocks.length; r++) {
      int dcCount = rsBlocks[r].dataCount;
      int ecCount = rsBlocks[r].totalCount - dcCount;
      maxDcCount = max(maxDcCount, dcCount);
      maxEcCount = max(maxEcCount, ecCount);
      dcdata[r] = List<int>.filled(dcCount, 0, growable: false);
      for (int i = 0; i < dcCount; i++) {
        dcdata[r][i] = 0xff & buffer.buffer[i + offset];
      }
      offset += dcCount;
      QRPolynomial rsPoly =
          QRPolynomial.errorCorrectPolynomialOfLength(ecCount);
      QRPolynomial rawPoly = QRPolynomial(dcdata[r], shift: rsPoly.count - 1);
      QRPolynomial modPoly = rawPoly.modedBy(rsPoly);
      ecdata[r] = List<int>.filled(rsPoly.count - 1, 0, growable: false);
      for (int i = 0; i < ecdata[r].length; i++) {
        int modIndex = i + modPoly.count - ecdata[r].length;
        ecdata[r][i] = (modIndex >= 0) ? modPoly.get(modIndex) : 0;
      }
    }
    int totalCodeCount = 0;
    for (int i = 0; i < rsBlocks.length; i++) {
      totalCodeCount += rsBlocks[i].totalCount;
    }
    List<int> data = List<int>.filled(totalCodeCount, 0, growable: false);
    int index = 0;
    for (int i = 0; i < maxDcCount; i++) {
      for (int r = 0; r < rsBlocks.length; r++) {
        if (i < dcdata[r].length) {
          data[index++] = dcdata[r][i];
        }
      }
    }
    for (int i = 0; i < maxEcCount; i++) {
      for (int r = 0; r < rsBlocks.length; r++) {
        if (i < ecdata[r].length) {
          data[index++] = ecdata[r][i];
        }
      }
    }
    return data;
  }
}

extension QRCodeModelExtension on QRCodeModel {
  QRMaskPattern _getBestMaskPattern() {
    int minLostPoint = 0;
    int pattern = 0;
    for (int i = 0; i < 8; ++i) {
      _makeImplIsTest(true, QRMaskPatternExtension.pattern(i));
      int lostPoint = this.lostPoint();
      if (i == 0 || minLostPoint > lostPoint) {
        minLostPoint = lostPoint;
        pattern = i;
      }
    }
    return QRMaskPatternExtension.pattern(pattern);
  }

  int lostPoint() {
    // TODO: Remove if needed
    // let moduleCount = self.moduleCount
    int lostPoint = 0;
    for (int row = 0; row < moduleCount; row++) {
      for (int col = 0; col < moduleCount; col++) {
        int sameCount = 0;
        bool dark = isDark(row, col);
        for (int r = -1; r <= 1; r++) {
          if (row + r < 0 || moduleCount <= row + r) {
            continue;
          }
          for (int c = -1; c <= 1; c++) {
            if (col + c < 0 || moduleCount <= col + c) {
              continue;
            }
            if (r == 0 && c == 0) {
              continue;
            }
            if (dark == isDark(row + r, col + c)) {
              sameCount += 1;
            }
          }
        }
        if (sameCount > 5) {
          lostPoint += (3 + sameCount - 5);
        }
      }
    }
    for (int row = 0; row < moduleCount - 1; row++) {
      for (int col = 0; col < moduleCount - 1; col++) {
        int count = 0;
        if (isDark(row, col)) {
          count += 1;
        }
        if (isDark(row + 1, col)) {
          count += 1;
        }
        if (isDark(row, col + 1)) {
          count += 1;
        }
        if (isDark(row + 1, col + 1)) {
          count += 1;
        }
        if (count == 0 || count == 4) {
          lostPoint += 3;
        }
      }
    }
    for (int row = 0; row < moduleCount; row++) {
      for (int col = 0; col < moduleCount - 6; col++) {
        if (isDark(row, col) &&
            isLight(row, col + 1) &&
            isDark(row, col + 2) &&
            isDark(row, col + 3) &&
            isDark(row, col + 4) &&
            isLight(row, col + 5) &&
            isDark(row, col + 6)) {
          lostPoint += 40;
        }
        if (isDark(col, row) &&
            isLight(col + 1, row) &&
            isDark(col + 2, row) &&
            isDark(col + 3, row) &&
            isDark(col + 4, row) &&
            isLight(col + 5, row) &&
            isDark(col + 6, row)) {
          lostPoint += 40;
        }
      }
    }
    int darkCount = 0;
    for (int col = 0; col < moduleCount; col++) {
      for (int row = 0; row < moduleCount; row++) {
        if (isDark(row, col)) {
          darkCount += 1;
        }
      }
    }
    int ratio = (100 * darkCount / moduleCount / moduleCount - 50).abs() ~/ 5;
    lostPoint += ratio * 10;
    return lostPoint;
  }
}
