enum ImportSourceType { pdf, excel }

extension ImportSourceTypeX on ImportSourceType {
  String get label => this == ImportSourceType.pdf ? 'PDF' : 'Excel';

  List<String> get allowedExtensions {
    switch (this) {
      case ImportSourceType.pdf:
        return const <String>['pdf'];
      case ImportSourceType.excel:
        return const <String>['xls', 'xlsx'];
    }
  }

  String get description {
    switch (this) {
      case ImportSourceType.pdf:
        return '适合教务系统导出的文本型课表 PDF';
      case ImportSourceType.excel:
        return '优先支持规整的 xls / xlsx 课表';
    }
  }
}
