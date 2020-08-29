extension intExtension on int {
  int zeroFillRightShift(int amount) {
    //return this/*.toUnsigned(this.bitLength)*/ >> amount;
    //int xxx = (this & 0xffffffff) >> amount;
    //return xxx.toUnsigned(xxx.bitLength);
    return this >> amount;
    //return (this & 0xffffffff) >> amount;
  }
}
