# Claude Code 最佳实践

> **你的 AI Coding 效果不好，有可能是工具、技能、插件太多。**

> 上下文窗口只有几百K，每个插件都在蚕食它。减少噪声是提升效率的第一原则。

---

## 1. CLAUDE.md 即是记忆，代码即是文档

### 层级结构

```
~/.claude/CLAUDE.md          # 全局规则：极简，只写跨项目通用的偏好
~/project/CLAUDE.md          # 项目规则：主要规则来源
~/project/src/CLAUDE.md      # 目录规则：模块级补充（按需）
```

### 核心原则

- **不需要额外记忆插件**。代码本身、注释、docs/、CLAUDE.md 已经是完整的上下文。
- CLAUDE.md 写**规则和约定**，不写代码逻辑。逻辑读代码。
- 项目 CLAUDE.md 应包含：技术栈、代码风格、禁止行为、常用命令、架构约定。
- 全局 CLAUDE.md 只放真正跨项目的偏好（如语言偏好、输出风格），**保持 < 50 行**。

### 好的范例：规则写进 CLAUDE.md，而非装成插件

[andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) 是这个理念的最佳示范——**一个 CLAUDE.md 文件，零插件，解决 LLM 编码的核心陋习**。

源自 Andrej Karpathy 的四条原则，直接 `curl` 进项目 CLAUDE.md 即可使用：

| 原则 | 解决的问题 |
|---|---|
| **编码前思考** | 不假设、不隐藏困惑、暴露权衡取舍 |
| **极简优先** | 过度设计、臃肿抽象、不必要的配置化 |
| **手术式修改** | 改动扩散到无关代码、顺手"优化"旁边的代码 |
| **目标驱动执行** | 给成功标准而非步骤，让 Claude 自己验证循环 |

```bash
# 追加到现有项目 CLAUDE.md
curl https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/CLAUDE.md >> CLAUDE.md
```

> **关键洞察**：好的行为约束放进 CLAUDE.md > 装成 Plugin/Skill。  
> Plugin 占用上下文空间且跨项目生效；CLAUDE.md 按项目隔离，随 git 一起版本化。

### 项目 CLAUDE.md 模板

```markdown
# 项目名

## 技术栈
- 语言/框架版本
- 包管理器

## 开发命令
- 启动：`npm dev`
- 测试：`npm test`
- 构建：`npm build`

## 代码约定
- 命名规范、文件结构
- 禁止事项（如不用 any、不 mock DB）

## 架构说明
- 模块职责简述
- 关键路径说明
```

---

## 2. 提示词：准确优于啰嗦

### 好提示词的特征

| 差 | 好 |
|---|---|
| "优化这段代码" | "减少 `processOrders()` 的嵌套层级，保持逻辑不变" |
| "修复 bug" | "修复 `auth.ts:142` 的空指针，`user` 可能为 undefined" |
| "加个功能" | "在 `UserList` 组件加分页，每页 20 条，复用现有 `Pagination` 组件" |

### 规则

1. **指定文件和行号**，而不是描述症状
2. **说明约束条件**：不改接口、不引入新依赖、保持现有测试通过
3. **给出验收标准**：怎样算完成
4. 一次请求**只做一件事**，复杂任务分步

---

## 3. 规则管理：全局精简，项目专注

### 原则

- **全局规则**：只放语言偏好、输出风格等不依赖项目的内容
- **项目规则**：技术栈约定、禁止行为、业务规范
- **目录规则**：模块特有约定（如 API 层不直接操作 DB）

### MCP / Plugin / Skill / Agent 配置

每一项扩展都会将自身的 tool definitions、system prompt 片段注入上下文，**无论你用不用它，空间都被占掉了**。

#### 大忌：大杂烩式安装

> [everything-claude-code](https://github.com/affaan-m/everything-claude-code) 这类"全家桶"包，一次性装入几十个 MCP、Skill、Agent。  
> **克制安装**，每新增一项都问自己：这个项目真的需要它吗？

#### 安装原则

| 类型 | 全局 | 项目级 |
|---|---|---|
| MCP | 只留通用工具（文件系统、搜索） | 按需：Figma（设计项目）、Playwright（UI 测试）、数据库（后端项目） |
| Skill | 只留高频跨项目的（如 /commit） | 按需：前端设计 Skill 只在前端项目装 |
| Agent | 不建议全局装自定义 Agent | 专项任务用完即删 |
| Plugin | 最小化，每个都是上下文负担 | 优先项目级安装 |

#### 项目级禁用示例

```jsonc
// .claude/settings.json（项目级）
{
  "mcpServers": {
    // 只声明本项目需要的
  },
  "disabledMcpServers": [
    "figma",       // 纯后端项目不需要
    "playwright",  // 非 UI 项目不需要
    "notebooklm"   // 与本项目无关
  ]
}
```

---

## 4. Plan → Execute：先想清楚再动手

### 工作流

```
1. 描述任务
2. Claude 进入 Plan 模式，探索代码，给出方案
3. 审查方案：文件范围、改动点、潜在风险
4. 确认后执行
5. 验证结果
```

### 何时强制 Plan

- 改动超过 3 个文件
- 涉及数据库 schema 变更
- 修改公共接口/API
- 重构或架构调整

### 触发方式

- 快捷键 `Shift+Tab` 切换 Plan/Execute 模式
- 提示词末尾加：`先分析再执行，列出改动文件和方案后等我确认`

> Plan 模式下 Claude **不会执行任何写操作**，只读代码、给方案。这是它的安全特性。

---

## 5. 上下文管理：减少噪声

### .claudeignore：从源头减噪

类似 `.gitignore` 语法，排除 Claude 不需要索引和读取的文件：

```gitignore
# .claudeignore
node_modules/
dist/
build/
*.min.js
*.lock
coverage/
.next/
```

**直接减少 Claude 索引的文件数量**，与本文核心理念高度一致。

### 上下文污染源

| 来源 | 影响 | 对策 |
|---|---|---|
| 全局 MCP tool definitions | 每个 MCP 几百 token | 只启用必要的 |
| 冗长的 CLAUDE.md | 每次都注入 | 精简到关键规则 |
| 过长的对话历史 | 稀释相关信息 | 任务完成后开新会话 |
| 无关文件被 Read | 占用窗口 | 明确指定文件路径 |
| 大型 diff/日志 | 快速消耗上下文 | 只粘贴关键片段 |

### 实践建议

- **一个任务一个会话**，完成后开新对话，不要在同一会话累积无关历史
- 贴代码时只贴**相关函数**，不贴整个文件
- 错误日志只贴**关键错误行**，不贴完整 stack trace
- 让 Claude 用 `Grep`/`Glob` 自己找文件，而不是把所有文件都 `Read` 进来

### 长会话拆分

单次对话超过上下文窗口 60-70% 后，效果显著下降。

- 用 `/compact` 主动压缩当前对话
- 大任务拆成多轮，每轮产出写入文件，下轮从文件继续
- 在 CLAUDE.md 记录"当前进度检查点"，新会话可直接衔接

---

## 6. 迭代节奏：小步快跑

### 原则

- 每次改动后**立即验证**（跑测试/刷新页面）
- 不要攒一大批改动一起验证
- 出错时**先读错误**，再决定是否重试
- 不要让 Claude 连续执行超过 5 步而不验证

### 工作单元

```
改动 → 验证 → 改动 → 验证
  ↑___________↑
     最小循环
```

---

## 7. 权限模式：安全与效率的平衡

### 三种模式

| 模式 | 适用场景 | 风险 |
|---|---|---|
| **默认（审批模式）** | 日常开发，推荐 | 低，每步确认 |
| **`--allowedTools` 精细授权** | 熟悉的项目，高频操作 | 中，可控 |
| **`--dangerously-skip-permissions`** | 一次性脚本、沙盒环境 | 高，无确认 |

### 推荐：精细授权

```bash
# 只放行读操作和 git，写操作仍需确认
claude --allowedTools "Bash(git *)" "Read" "Grep" "Glob"
```

> Yolo 模式（`--dangerously-skip-permissions`）听起来很爽，但在真实项目上一次误操作的代价远高于多点几次确认。

---

## 8. Hooks：让自动化替你省上下文

在 `.claude/settings.json` 配置 hooks，减少"修格式"等无效来回：

```jsonc
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "eslint --fix $CLAUDE_FILE_PATH"
      }
    ]
  }
}
```

### 典型场景

- **PostToolUse**：每次编辑后自动 lint/format，避免攒到最后才发现
- **PreCommit**：commit 前自动跑类型检查
- **自定义校验**：写入文件后检查是否符合项目规范

> 每次让 Claude 手动修格式都是浪费上下文。Hook 一劳永逸。

---

## 9. 版本控制集成

- 任何大改动前先 `git commit`，给 Claude 一个干净的起点
- 用 `git diff` 审查 Claude 的改动，再决定是否 commit
- 复杂任务用 worktree 隔离：`/worktree feature-xxx`，完成后合并
- 让 Claude 自动生成 commit message：`/commit`

---

## 10. 安全边界

Claude Code 默认会请求确认高风险操作，但养成习惯：

- **永远不要** 让 Claude 在没有确认的情况下 `force push`、`DROP TABLE`、`rm -rf`
- 生产环境操作前明确说："这是生产环境，每步都要我确认"
- 敏感文件（`.env`、credentials）加入 `.gitignore`，不要让 Claude commit

---

## 11. 子代理（Subagent）策略

子代理在独立上下文中运行，结果摘要回传，**不污染主上下文**。

### 何时用

| 场景 | 方式 |
|---|---|
| 简单查找（找函数、找文件） | 直接 Grep/Glob，不启子代理 |
| 中等复杂探索（理解一个模块） | Explore agent |
| 多路并行调研 | 同时启多个子代理，各查各的 |
| 批量重构（改 20 个文件的同一模式） | 子代理隔离执行，主会话汇总 |

### 原则

- **不要为简单操作启子代理**——启动成本不值得
- 并行子代理用于**独立且互不依赖**的子任务
- 子代理可配置用较低成本模型（如 Haiku），省钱不占主上下文

---

## 12. 模型选择策略

不同任务适配不同模型，别一把梭哈最贵的：

| 模型 | 擅长 | 适用场景 |
|---|---|---|
| **Opus** | 复杂推理、架构设计、大范围重构 | Plan 阶段、疑难 bug、跨模块设计 |
| **Sonnet** | 日常编码、平衡性价比 | 功能开发、代码审查、常规修复 |
| **Haiku** | 快速响应、简单任务 | 子代理调研、格式化、简单查询 |

```bash
# 日常开发用 Sonnet
claude --model sonnet

# 复杂设计切 Opus
# 会话中用 /model 切换
```

> 用 Opus 来修 typo 是浪费；用 Haiku 来做架构设计是勉强。匹配任务复杂度。

---

## 速查：反模式清单

- [ ] 全局 CLAUDE.md 超过 100 行
- [ ] 启用了与当前项目无关的 MCP
- [ ] 同一会话处理多个不相关任务
- [ ] 直接让 Claude 执行而不先 Plan
- [ ] 把整个文件贴进提示词
- [ ] 忽略错误继续让 Claude 重试
- [ ] 让 Claude 在单次对话中改动超过 10 个文件
- [ ] 在全局配置里放项目专用规则
- [ ] 全程用 Opus 做简单任务
- [ ] Yolo 模式用在真实项目上
- [ ] 没配 .claudeignore，node_modules 被索引
- [ ] 会话超长不 /compact，效果越来越差
