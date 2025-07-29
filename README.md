# *TimeLemon* - 社会事件爬取梳理与可视化

![Dart](https://img.shields.io/badge/Dart-3.8.2-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

TimeLemon 是一个用 `Dart` 编写的工具，用于爬取多个平台的热搜榜单数据，筛选梳理社会实践，并将其转换为 `JSON` 格式，同时提供可视化功能。

## 功能特性

- [ ] 📊 多平台热搜数据采集（Bilibili、微博、百度、知乎、抖音等）
    - [x] Bilibili
    - [ ] 微博
    - [ ] 百度
    - [ ] 知乎
    - [ ] 抖音
- [x] 🗃️ 结构化 `JSON` 数据输出
- [ ] 📈 数据可视化功能
- [ ] ⚡ 高性能异步爬取
- [ ] 🔍 数据去重与清洗

### 输出格式

程序会生成如下结构的 `JSON` 文件：

```json
[
    {
        "event": "武大图书馆诬告案",
        "category": "社会民生",
        "sign": "important"
    },
    {
        "event": "北京因灾死亡30人",
        "category": "公共安全",
        "sign": "urgent"
    },
    {
        "event": "北方暴雨为何如此猛烈",
        "category": "公共安全",
        "sign": "important"
    },
    {
        "event": "育儿补贴释放什么信号",
        "category": "社会民生",
        "sign": "important"
    }
]
```

## 可视化

暂无

## 贡献

欢迎提交 [Issue](https://github.com/WillSat/timelemon/issues) 和 Pull Request！

## 许可证

MIT License