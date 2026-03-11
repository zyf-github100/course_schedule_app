# 课程表 App

一个基于 Flutter 的课程表应用，当前已经完成从文件导入到确认、保存、查看的 MVP 闭环。

## 当前状态

截至 2026-03-11，项目已经具备这些能力：

- 支持导入 `Excel` 课表，并按规整表头格式做真实解析
- 支持导入文本型 `PDF` 课表，并做规则识别
- 提供“解析中 -> 确认结果 -> 保存课表”的完整流程
- 确认页支持新增、编辑、删除课程草稿
- 课表支持本地保存、当前学期切换、学期设置
- 首页和课表页支持真实数据展示
- 课表页支持周视图、日视图、课程冲突提示、详情查看
- 首页支持展示最近导入记录

## 当前实现

核心闭环已经从规划进入可用状态：

`导入文件 -> 自动解析 -> 人工确认 -> 保存本地课表 -> 首页/课表页查看`

当前仍然保留的限制：

- `Excel` 解析优先支持规整模板，复杂合并单元格仍需样例驱动继续兼容
- `PDF` 解析当前只适合文本型或结构较清晰的文件
- 扫描版 PDF / 图片课表暂不支持
- 尚未接入系统日历、上课提醒、OCR、多端同步

## 技术实现

- 框架：`Flutter`
- 语言：`Dart`
- 文件选择：`file_picker`
- Excel 解析：`excel`
- PDF 文本提取：`syncfusion_flutter_pdf`
- 本地存储：`shared_preferences`

## 目录结构

```text
lib/
  app/
  core/
  features/
    home/
    import/
    schedule/
    settings/
  shared/
test/
```

目前采用 `feature-first` 结构，导入、课表、设置已经拆分到独立模块。

## 里程碑状态

- [x] Milestone 1：基础结构整理
- [x] Milestone 2：导入流程骨架
- [x] Milestone 3：Excel 导入 MVP
- [x] Milestone 4：保存与展示
- [x] Milestone 5：PDF 导入 MVP
- [x] Milestone 6：体验优化与冲突提示
- [ ] 下一阶段：样例驱动解析增强 / 日历导出 / 提醒 / OCR

## 当前推荐下一步

现在不再是补页面骨架，而是继续做这三类工作：

1. 建立真实 `Excel/PDF` 样例回归集，继续强化解析规则
2. 评估“导出到系统日历”或“上课提醒”作为下一项用户功能
3. 为扫描版 PDF / 图片课表预留 OCR 方案

## 常用命令

```bash
D:\flutter\bin\flutter.bat analyze
D:\flutter\bin\flutter.bat test
D:\flutter\bin\flutter.bat run
```

## 文档说明

- `README.md`
  - 当前状态、能力范围、运行方式
- `DEVELOPMENT_PLAN.md`
  - 产品和阶段规划
- `ENGINEERING_PLAN.md`
  - 工程实现和下一步技术重点
