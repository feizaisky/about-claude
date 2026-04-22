# About Claude

关于 Claude 和 Claude Code 的工具与文档合集。

## 目录结构

```
./
├── index.html                          # 项目导航首页
├── README.md                           # 本文件（首页文字来源）
├── claude-code-cheatsheet.md           # 新手速查手册（Markdown 源）
├── claude-code-best-practices.md       # 日常最佳实践（Markdown 源）
└── outhtml/
    ├── doc.css                         # 两份文档共享的样式
    ├── cheatsheet.html                 # 从 cheatsheet.md 渲染
    ├── best-practices.html             # 从 best-practices.md 渲染
    └── viewer.html                     # Claude API 对话可视化工具（独立单页应用）
```

## 文件说明

### 文档

- **[新手速查手册](outhtml/cheatsheet.html)**（`claude-code-cheatsheet.md`）  
  面向第一次用 Claude Code 的人，覆盖安装启动、规划清单、提示词模板、4 类红线、4 个真实翻车剧本。
- **[日常最佳实践（进阶）](outhtml/best-practices.html)**（`claude-code-best-practices.md`）  
  减少噪声是提升效率的第一原则。CLAUDE.md 管理、Plan / Execute、`permissions.deny`、Hooks、子代理、模型选择等 12 个主题。

### 工具

- **[Claude API 对话可视化](outhtml/viewer.html)**  
  粘贴 Claude API 的请求/响应 JSON，解析并展示对话时间线、Token 用量、工具调用详情。纯前端、零依赖。

## 使用方法

浏览器直接打开 `index.html` 即可，或双击 `outhtml/` 下的任一 HTML 文件。**无需服务器**（文档 HTML 通过内嵌 Markdown + marked.js 渲染）。

## 如何更新文档

文档 HTML 的 Markdown 内容是**内嵌**在 HTML 里的。改完 `.md` 后需要重新生成对应 HTML：

```bash
./build-docs.sh
```

（脚本会把最新的两份 md 分别注入到 `outhtml/cheatsheet.html` 和 `outhtml/best-practices.html` 的 `<script type="text/markdown">` 占位块。）
