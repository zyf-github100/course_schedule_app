# 课程表 App 工程化开发计划

## 1. 文档目的

这份文档用于同步当前仓库的真实工程状态，并明确下一阶段的技术重点。

## 2. 当前工程状态

截至 2026-03-11，项目已经落地为可运行的 Flutter 应用，而不是早期骨架工程。

当前已完成：

- `feature-first` 目录结构
- `app/routes.dart` 路由管理
- 首页、导入、课表、设置四个主模块
- `Excel` / `PDF` 两条导入解析链路
- `ImportDraft` 确认与保存流程
- 基于 `shared_preferences` 的本地持久化
- 多学期切换与设置同步
- 周视图 / 日视图 / 冲突检测
- 最近导入记录持久化与首页展示
- 单元测试与 Widget 测试

## 3. 当前架构

项目继续采用 `Feature First + 分层结构`：

```text
lib/
  app/
    app.dart
    routes.dart
    theme/
  core/
    constants/
    utils/
  features/
    home/
    import/
      data/
      domain/
      presentation/
    schedule/
      data/
      domain/
      presentation/
    settings/
      data/
      domain/
      presentation/
  shared/
    widgets/
```

当前实现重点：

- UI 和解析逻辑已分离
- 导入确认与课表存储已分离
- `ExcelScheduleParser` 和 `PdfScheduleParser` 已独立
- 本地存储目前统一落在 `shared_preferences`

## 4. 当前依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  excel: ^4.0.6
  file_picker: ^8.0.0
  shared_preferences: ^2.5.3
  syncfusion_flutter_pdf: ^32.2.4
```

说明：

- 当前 MVP 已经使用 `shared_preferences`，暂未引入 `Hive / Isar`
- PDF 方案当前选用 `syncfusion_flutter_pdf` 做文本提取

## 5. 当前数据流

### 5.1 Excel 导入

```text
ImportEntryPage
  -> ImportController.pickFile()
  -> ImportParsingPage
  -> ExcelScheduleParser.parse()
  -> ImportReviewPage
  -> ScheduleRepository.saveSemester()
  -> ImportHistoryRepository.saveHistoryEntry()
  -> HomePage / SchedulePage
```

### 5.2 PDF 导入

```text
ImportEntryPage
  -> ImportController.pickFile()
  -> ImportParsingPage
  -> PdfScheduleParser.parse()
  -> ImportReviewPage
  -> ScheduleRepository.saveSemester()
  -> ImportHistoryRepository.saveHistoryEntry()
  -> HomePage / SchedulePage
```

## 6. 里程碑同步

- [x] Milestone 1：基础结构整理
- [x] Milestone 2：导入流程骨架
- [x] Milestone 3：Excel 导入 MVP
- [x] Milestone 4：保存与展示
- [x] Milestone 5：PDF 导入 MVP
- [x] Milestone 6：体验优化

其中 Milestone 6 当前已覆盖：

- 更完整的首页和课表 UI
- 课程颜色展示
- 冲突检测
- 周 / 日视图切换
- 最近导入记录

## 7. 当前工程短板

虽然主链路已经可用，但工程上还存在这些短板：

1. 解析准确率仍依赖少量规则，真实学校样例覆盖还不够
2. 缺少面向真实文件样例的回归测试资产
3. 目前没有提醒、系统日历、OCR 等增强模块抽象

## 8. 下一阶段技术重点

### 8.1 样例驱动解析增强

建议优先完成：

- 建立 `Excel` / `PDF` 样例目录
- 为每类样例补充 parser 回归测试
- 扩充合并单元格、跨行文本、异常周数、乱码标题等规则

### 8.2 增强功能预研

在解析稳定后，建议二选一启动：

1. 系统日历导出
2. 上课提醒

这一步建议先抽象独立服务接口，避免直接把平台逻辑写进页面层。

### 8.3 OCR 预留

如果后续要支持扫描版 PDF / 图片课表，建议新增独立 OCR 解析器，而不是把 OCR 逻辑混进现有 PDF parser。

## 9. 测试状态

当前验证方式：

```bash
D:\flutter\bin\flutter.bat analyze
D:\flutter\bin\flutter.bat test
```

本次文档同步时，分析与测试均已通过。

## 10. 当前结论

工程侧已经完成 MVP 闭环，当前不应再把“搭骨架”作为下一步。下一阶段的重点应转为：

- 用真实样例继续提高解析稳定性
- 选择一个增强功能继续扩展产品能力
