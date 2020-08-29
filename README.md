# qrcoder

[![pub package](https://img.shields.io/pub/v/qrcoder.svg)](https://pub.dartlang.org/packages/qrcoder)

Yet another stupid flutter qrcode plugin, modified from [qrcodejs](https://github.com/davidshimjs/qrcodejs) & [swift_qrcodejs](https://github.com/ApolloZhu/swift_qrcodejs).

## Use

1. Dependency

In your `pubspec.yaml`, add the following config:

```yaml
dependencies:
   qrcoder: 0.1.0
```

2. Generate

The method statement is as follows:

```dart
static Future<List<List<int>>> generateQRCodeMatrix(
	String text, {Encoding encoding = utf8, QRErrorCorrectLevel errorCorrectLevel = QRErrorCorrectLevel.H, bool hasBorder = true}
)
```

You can call this method liek this:

```dart
var matrix = await Qrcoder.generateQRCodeMatrix('2333', hasBorder: false);
print(matrix);
```

For more information, you can see the [example](https://github.com/EyreFree/qrcoder/tree/master/example) project.

## Author

EyreFree, eyrefree@eyrefree.org

## License

![](https://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/License_icon-mit-88x31-2.svg/128px-License_icon-mit-88x31-2.svg.png)

This project is available under the MIT license. See the LICENSE file for more info.
