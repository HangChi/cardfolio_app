# Feature 008 数据模型与格式

## ZIP

```text
cardfolio-backup-YYYYMMDD-HHmmss.zip
├── manifest.json
├── data.json
└── images/
    └── <数据库中的规范相对路径>
```

## manifest.json

```json
{
  "format": "cardfolio-backup",
  "formatVersion": 1,
  "sourceSchemaVersion": 9,
  "createdAt": "2026-07-29T00:00:00.000Z",
  "dataFile": "data.json",
  "entries": [
    {"path": "data.json", "byteSize": 123, "sha256": "<64 lowercase hex>"}
  ],
  "entityCounts": {"cardDefinitions": 1}
}
```

`entries` 不包含 `manifest.json`，避免自引用校验。图片条目路径为
`images/<relativePath>`。

## data.json

顶层包含 `logicalSchemaVersion` 和 `entities`。`entities` 固定包含：

`cardDefinitions`、`cardItems`、`cardImages`、`cardSets`、`cardSetMembers`、
`tags`、`cardTags`、`seriesRecords`、`seriesCards`、`seriesSets`、
`customFieldDefinitions`、`customFieldValues`、`purchases`、`purchaseItems`、
`exchangeRates`、`recycleBinSettings`、`fileCleanupQueue`。

字段使用稳定 lowerCamelCase 逻辑名；时间为 UTC ISO-8601，金额为最小货币单位整数，
枚举为稳定字符串，图片只保存规范相对路径。

`cardSets[*].coverRelativePath` 与 `seriesRecords[*].coverRelativePath` 是可空逻辑字段。
非空时对应文件必须进入 ZIP 的 `images/<relativePath>`、清单和 SHA-256 校验；导入预览
若缺少任一引用封面必须失败且不能修改现有收藏。旧格式缺少套卡独立封面字段时按 `null`
规范化，不提升备份格式版本。

## 导入顺序

父表顺序：款式、藏品、图片、套卡、成员、标签、系列、自定义字段、购买、汇率、设置；
多对多和值表在父表后；文件清理队列最后。导出数组按主键稳定排序，便于相同记录比较。

## 兼容矩阵

| 导出格式 | 当前导入器 | 处理 |
|---:|---:|---|
| 1 | 1 | 支持，经过 v1 规范化器 |
| < 1 | 1 | 拒绝，格式过旧 |
| > 1 | 1 | 拒绝，需更新应用 |

新增可选字段时保持格式版本并提供默认值；删除/重命名字段或改变语义时提升版本并增加
逐版本纯函数迁移与旧夹具测试。
