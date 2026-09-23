# 任务1调研报告

## 官方评测竞赛的检索数据集与评价工具调研

**报告日期**：2026 年 9 月 23 日
**任务编号**：任务 1
**任务目标**：调研官方公开举办的评测竞赛所提供的检索评测数据集与评价工具，形成可执行的跑通清单
**交付物**：`/workspace/trec-eval-kit/`（文档 + 三个已验证脚本 + 真实官方数据）

---

## 第一章 任务概述

### 1.1 提示词回溯

本次任务由用户当日上午连续三次提问逐步收敛而成，原文如下。

**提示词一（需求萌发）**

> 请问搜索引擎的评测数据集

**提示词二（边界收敛）**

> 要求官方公开举办的评测竞赛的数据集与评价工具

**提示词三（执行排序）**

> 两个都要，不过一个一个来，先完成1，再做2

**提示词四（本报告成因）**

> 请为1和2两项任务分别撰写名为"任务1调研报告.pdf"与"任务2调研报告.pdf"的文档报告，报告中，请将今天早上与任务相关的所有我发给你的提示词，以及你的深度思考过程，及如何解决任务的思路，以及重点描述任务涉及的国内外评测竞赛的前世今生，技术路线，评价数据集，评测指标与评测工具等内容

### 1.2 需求界定

三次提问构成一条清晰的收敛链：

| 轮次 | 用户输入 | 关键增量 | 对方案的影响 |
|---|---|---|---|
| 一 | "搜索引擎的评测数据集" | 宽泛咨询 | 需先做范围界定，不能上来就列清单 |
| 二 | "官方公开举办的评测竞赛" | **限定为 Evaluation Campaign / Shared Task** | 排除 BEIR、MTEB、C-MTEB 一类民间 benchmark 集合 |
| 三 | "先完成1，再做2" | 串行执行约束 | 任务1（跑通清单）先交付，任务2（自建方案）后交付 |

第二轮的限定词是整个任务的分水岭。它把"有哪些数据可以测"变成了"哪些机构有权发布标准答案"。

---

## 第二章 分析过程与解决思路

### 2.1 第一个判断：先划清"官方"与"民间"的界线

拿到"评测数据集"这个宽泛提问时，最直接的回答是列 BEIR、MTEB、C-MTEB 这类常见榜单。但这条路是错的——用户第二轮明确要求"官方公开举办的评测竞赛"，说明他要的是可引用、可对甲方/审稿人交代的权威来源。

两者的本质差别不在数据质量，而在**是否有组织机制**：

| 维度 | 官方评测竞赛 | 民间 benchmark 集合 |
|---|---|---|
| 组织方 | NIST、NII、CLEF 协会等常设机构 | 研究者自发整理 |
| 参与方式 | 注册参赛、提交 run | 无需注册，直接下载 |
| 标准答案 | 组委会发布 qrels | 沿用上游数据集自带标注 |
| 评分程序 | 官方 scorer，唯一权威实现 | 各家自行实现，边界处理不一 |
| 成果形式 | 官方 proceedings / overview 论文 | 排行榜 |
| 可引用性 | 可写"参加 TREC 2025 RAG" | 只能写"在公开 benchmark 上评测" |

这个判断直接决定了报告第一章的存在——它帮用户避开一个在论文中会被审稿人直接点破的表述错误。

### 2.2 第二个判断：先核实，再动笔

信息检索评测领域的数据集名称、规模、MD5、赛道设置在近两年变化很快（TREC 每年换 track，MS MARCO 语料版本迭代到 V2.1）。凭记忆写清单风险极高，尤其在用户要拿去做正式材料时。

因此执行顺序定为：**联网核实 → 下载真实数据 → 本地跑通 → 再写文档**。共发起六次检索，覆盖 BEIR 现状、中文评测集、TREC 2025 赛道设置、NTCIR/CLEF 官方工具、TREC DL 数据口径、UMBRELA 自动判定。

核实过程中修正了三处初始偏差：

1. **TREC 2025 的赛道与我预期不同**——实际为 AVS、BioGen、DRAGUN、iKAT、Million LLM、Product Search、RAG、RAGTIME、ToT、VQA 十个，其中 RAG 是第二届。
2. **TREC 2025 RAG 的查询形态变了**——从 2024 年的短关键词改为多句叙述型 narrative，并按"文档回答了多少个子叙述"打 0–4 分。
3. **评测工具链的安装条件受限**——沙箱访问 GitHub 的 TLS 握手失败，官方 `trec_eval` 无法克隆编译。

### 2.3 第三个判断：用实证代替描述

一份"跑通清单"如果没跑过，价值接近于零。因此决定**不下载 28 GB 语料**（无必要且耗时），而是下载体积很小但真实权威的官方 qrels 与 topics，在真实数据上端到端验证工具链。

设计三组对照实验，让结论自带证据：

| 实验 | 构造方式 | 预期 | 实际 | 证明什么 |
|---|---|---|---|---|
| Oracle | 按相关性降序的完美排序 | nDCG@10 = 1.0 | **1.0000** | 工具链与口径配置正确 |
| Shuffle | 随机打乱 | 明显低于 1.0 | **0.4034** | 指标具备区分度 |
| DocLevel | 去掉 `#段号` 退化为文档级 | 恒为 0 | **0.0000** | 粒度错配是致命且静默的坑 |

第三组尤其重要：它把一个"说起来像常识"的警告变成了有数值支撑的结论，并且直接催生了校验脚本中的 [D] 检查项。

### 2.4 第四个判断：工具链受阻时的等价替代

官方 `trec_eval` 编译失败后，有两条路：放弃验证、或找等价实现。选择后者——`pytrec_eval-terrier` 编译的是 NIST 同一份 C 源码，Anserini 与 Pyserini 的官方回归测试即用它，数值等价。

同时保留官方命令行路线，写成 `eval_official.sh`，并在评测输出中自动打印等价的 `trec_eval` 命令。这样两条路都给到用户，本机条件不同可自行切换。

### 2.5 执行路径总览

```
需求界定（官方 vs 民间）
        ↓
六次联网核实（TREC 2025 / DL 21-23 / NTCIR / CLEF / UMBRELA）
        ↓
下载真实官方 qrels + topics（NIST 直链）
        ↓
安装等价评测实现 pytrec_eval-terrier 0.5.10
        ↓
构造三组对照 run → 验证指标正确性
        ↓
编写校验器（把验证中发现的坑固化为检查项）
        ↓
编写评测脚本（Python 路线 + 官方二进制路线）
        ↓
撰写清单文档（数据集 / 工具 / 口径 / 基线 / 坑）
```

---

## 第三章 国内外评测竞赛的前世今生

### 3.1 史前阶段：Cranfield 范式（1950s–1966）

现代检索评测的一切规矩，来自英国 Cranfield 航空学院的 Cyril Cleverdon 团队。

| 要素 | Cranfield 的贡献 | 今天是否仍在用 |
|---|---|---|
| 测试集 | 1,398 篇航空学论文摘要 | 是的，只是规模换了数量级 |
| 查询集 | 225 条 | 是的 |
| 判定 | **穷尽式**，每个（查询, 文档）对都判 | 大规模语料下已不可行 |
| 指标 | 查全率、查准率 | 是的 |
| 结论 | 自动索引效果不逊于手工索引 | 已被后续推翻重议，但方法学留了下来 |

Cranfield 确立的核心思想是 **Cranfield 范式**：用固定的文档集、固定的查询集、固定的标准答案，在受控条件下比较不同系统。今天所有 TREC 风格评测都是这一范式的放大版。

1970 年代陆续出现 CACM、NPL 等小规模测试集，但规模始终停留在千余篇量级。到 1990 年代初，领域公认的瓶颈是：**没有真实规模的测试集，检索研究无法验证可扩展性**。

### 3.2 TREC：三十四年的行业标准（1992–2026）

**诞生**：1990–1991 年，DARPA 的 TIPSTER 项目委托 NIST 的 Donna Harman 构建大规模测试集，规模定为 2 GB 全文（报纸、新闻专线），远超当时常见的 2 MB 级实验数据。NIST 随后提议以此为基础召开评测会议，1992 年首届 TREC 召开，由 DARPA、NIST、美国国防部共同赞助。

**TREC-1（1992）**：25 个研究团队参与，任务是把原型系统从检索 2 MB 文本扩展到 2 GB。两个核心任务沿用至今的变体：

- **Ad hoc**：文档集固定，查询是新的（类似研究者用图书馆）
- **Routing**：查询固定，文档流是新的（类似新闻剪报服务）

每届 50 个主题，每主题提交 Top 1000 结果，由 NIST 统一评测。

**规模演进**：1992–1999 的八届 Ad hoc 测试集合计 6 张 CD、约 189 万篇文档、450 个主题。2000 年代进入 Web 时代，GOV2 达到 2,500 万网页。2010 年代后出现 ClueWeb 系列，2020 年代 MS MARCO V2.1 达到千万级文档、上亿级段落。

**方法学创新**：TREC 最重要的贡献是 **pooling**——不做穷尽判定，只把各参赛系统 Top-k 结果汇总去重后送人工判定。这让大规模语料上的评测成为可能，代价是引入了"未判定即不相关"的系统性偏差。

**现状（TREC 2025，第 34 届）**：2025 年 12 月 11–12 日线上召开，会议录为 NIST SP 1348（2026 年 3 月出版）。十个赛道：

| 赛道 | 全称 / 方向 |
|---|---|
| AVS | Ad-hoc Video Search，视频检索 |
| BioGen | Biomedical Generative Retrieval，生物医学生成式检索 |
| DRAGUN | 新闻的检测、检索与增强生成 |
| iKAT | Interactive Knowledge Assistance，交互式知识辅助 |
| Million LLM | 百万级 LLM 的能力识别 |
| Product Search | 商品搜索与推荐 |
| **RAG** | Retrieval-Augmented Generation，检索增强生成 |
| RAGTIME | 多语言新闻报告生成 + 引用评测 |
| ToT | Tip-of-the-Tongue，舌尖现象已知项检索 |
| VQA | Video Question Answering |

TREC 数据免费、参与开放，但官方明确规定 **TREC 结果不得用于广告宣传**。

### 3.3 欧洲、亚洲与其他官方评测

| 机构 | 起始 | 定位 | 与 TREC 的差异 |
|---|---|---|---|
| **CLEF** | 2000 | Conference and Labs of the Evaluation Forum，欧洲 | 早期主打欧洲语言跨语言检索；2010 年转为独立会议；2012 年 INEX（结构化文本）并入成为 lab；现含 eHealth、LongEval、Touché、CheckThat!、SimpleText、JOKER 等 |
| **NTCIR** | 1999 | 日本 NII 主办，东亚与多语言 | 从零构建日语、中文测试集，解决分词等语言差异问题；覆盖 Ad hoc、CLIR、QA、专利检索、_mathIR_、会话检索、金融（FinNum）、Lifelog；2026 年 LREC 仍设有"26 年历程"专题 |
| **FIRE** | 2008 | Forum for IR Evaluation，南亚 | 印地语、孟加拉语等南亚语言跨语言检索 |
| **TAC** | 2008 | NIST 主办，Text Analysis Conference | 偏文本分析：KBP 实体链接、RTE 文本蕴含、自动摘要 |
| **BioASQ** | 2012 | 欧盟资助的专题挑战 | 生物医学语义检索 + 问答，每年多批测试集，官方 Java 评测工具 |
| **COLIEE** | 2014 | 加拿大 Alberta 大学主办 | 法律案例检索 + 法律文本蕴含，是法律 IR 最权威的官方赛事 |
| **MS MARCO** | 2016 | 微软官方竞赛 | 基于 Bing 真实查询日志；TREC Deep Learning Track 以其为官方测试集 |

**MS MARCO 的特殊地位**：它不是学术机构主办，但由微软以官方竞赛形式运营（有排行榜、有官方评测脚本、有数据集授权协议），并且是 TREC Deep Learning Track 2019–2023 的指定语料。这使它事实上成为稠密检索时代的官方标准测试集。

### 3.4 国内情况

| 赛事 | 主办方 | 说明 |
|---|---|---|
| **CCKS 评测** | 中国中文信息学会（CIPS） | 全国知识图谱与语义计算大会，每年发布任务、数据与官方 scorer |
| **NLPCC Shared Task** | CCF | 含中文检索、问答、语义匹配类任务 |
| **CCIR** | CCF 全国信息检索学术会议 | 国内 IR 主线会议，设评测赛道 |
| **SMP 评测** | CIPS 社会媒体处理专委 | 社交媒体检索与匹配 |
| **CCF BDCI / DataFountain / 天池** | 学会 + 企业 | 使用企业真实搜索日志（电商搜索、商品检索），提供 nDCG/MRR 评测脚本 |
| **CWIRF** | 中文网页检索评测论坛（早期） | 中文网页测试集 CWT100G，2000 年代的基础性工作 |

国内赛事有两个特点需要留意：**赛道设置每年变动大**，须以当届官网通知为准；**多数数据赛后不公开**，需在赛事期间报名获取。这决定了它们适合"参赛"而不适合"事后复现研究"。

### 3.5 演进规律

| 时期 | 驱动问题 | 语料规模 | 判定方式 | 主指标 |
|---|---|---|---|---|
| 1960s | 自动索引是否可行 | 千篇 | 穷尽判定 | P / R |
| 1992–2000 | 统计方法能否扩展 | 百万篇 | pooling + 人工 | MAP、P@10 |
| 2000–2015 | Web 检索、垃圾页面、多样性 | 千万–亿级网页 | pooling + 人工 | nDCG、ERR、α-nDCG |
| 2016–2022 | 神经/稠密检索、跨领域泛化 | 千万文档/亿段落 | pooling + 人工 | nDCG@10、MRR@10、R@1000 |
| 2023–2026 | RAG、生成式答案、归因 | 同左 + 多语言 | **LLM 自动判定 + 人工后编辑** | nDCG@20/100、nugget 覆盖、支持度 |

最值得注意的转折在最后一行：**标准答案的 produced 方式正在从纯人工转向 LLM 主导**。

### 3.6 UMBRELA：判定方式的范式转移

TREC 2024 RAG Track 首次在正式评测中大规模部署 LLM 判定。UMBRELA（UMbrela is the (Open-Source Reproduction of the) Bing RELevance Assessor）用 GPT-4o 以零样本方式对（查询, 段落）打 0–3 分。

官方评测流程为三段式：

1. **相关性判定**：UMBRELA 自动打分生成 Auto Qrels → 人工后编辑生成 Post-Edited Qrels（用于 Retrieval 任务评测）
2. **Nugget 构建**：LLM 从相关段落中自动抽取原子事实单元（Auto Nuggets）→ 人工增删改（Post-Edited Nuggets）
3. **答案评测**：对生成答案逐句做支持度（0–2：无/部分/完全）、流畅度、nugget 覆盖度判定

NIST 于 2025 年 7 月发布的大规模研究（77 个 run、19 支队伍）结论是：UMBRELA 自动判定与全人工判定在系统排序上高度相关（Kendall's τ 约 0.890），**可替代全人工用于 run 级有效性比较**；且人工介入并未显著提升相关性；人工评估员比 UMBRELA 更严格。

这一结论对任务 2 有直接价值：自建评测集时，可以先用 LLM 大规模预打标，再对分歧项人工仲裁，成本可大幅下降。

---

## 第四章 技术路线演进

### 4.1 检索技术的四代路线

| 代际 | 时期 | 代表方法 | 评测关注点 |
|---|---|---|---|
| 第一代 | 1960s–1990s | 布尔模型、向量空间、TF-IDF、SMART 系统 | 查全/查准、索引效率 |
| 第二代 | 1990s–2010s | 概率模型、BM25、语言模型、查询扩展、学习排序（LTR） | MAP、nDCG、特征工程效果 |
| 第三代 | 2016–2022 | 稠密向量检索（DPR、ANCE）、迟交互（ColBERT）、学习稀疏（SPLADE）、混合检索 | 跨领域泛化、效率与效果权衡 |
| 第四代 | 2023– | LLM 重排、生成式检索、RAG、智能体式深度检索 | 答案正确性、归因可信度、nugget 覆盖 |

### 4.2 评测方法对技术演进的适配

评测不是被动跟随技术，而是在关键节点上主动塑造了技术方向：

- **BEIR 的教训**：2021 年 BEIR 证明稠密检索器在陌生领域常输给 BM25，直接催生了混合检索与学习稀疏检索的研究热潮。
- **TREC DL 的作用**：提供了 MS MARCO 之外由组委会统一判定的测试集，避免了"自己训自己测"的循环论证。
- **查询形态的升级**：TREC DL 2023 引入 T5/GPT-4 合成查询以提高难度；TREC RAG 2025 进一步改为多句叙述型查询，倒逼系统具备多跳推理与证据聚合能力。
- **评测对象的扩展**：从"排序列表"扩展到"带引用的生成答案"，于是需要 nugget、支持度等新指标。

### 4.3 本任务采用的技术路线

```
数据层：NIST 官方 qrels + topics（真实、可校验）
            ↓
工具层：pytrec_eval-terrier（等价官方 C 实现）+ 官方 trec_eval 二进制（备选）
            ↓
校验层：格式与语义双重校验（粒度、主题覆盖、深度、排序、runtag）
            ↓
评测层：nDCG@10 / MAP@100 / MRR / Recall@k / P@10，口径可配置
            ↓
验证层：三组对照 run，用已知预期值反向验证链路
```

---

## 第五章 评价数据集

### 5.1 TREC 2025 RAG Track

**语料**（沿用 2024，官方公告页提供直链，需同意 MS MARCO 使用协议）：

| 集合 | 文件 | 记录数 | 体积 | MD5 |
|---|---|---|---|---|
| MS MARCO V2.1 文档集 | `msmarco_v2.1_doc.tar` | 10,960,555 | 28.1 GB | `a5950665d6448d3dbaf7135645f1e074` |
| 同上（分段版） | `msmarco_v2.1_doc_segmented.tar` | 113,520,750 | 25.1 GB | `3799e7611efffd8daeb257e9ccca4d60` |

格式为 70 个 gzip JSONL 打包进 tar，字段含 `docid / url / title / headings / body`。分段方式为 10 句滑动窗口、步幅 5 句，段长 500–1000 字符。文档 docid 编码了文件名与字节偏移（如 `msmarco_v2.1_doc_29_677149`），便于随机读取。

**Topics 与 Qrels（NIST 官方直链，本任务已下载）**：

| 类型 | 地址 | 形态 |
|---|---|---|
| Topics（叙述型查询） | `trec.nist.gov/data/rag/trec25_narratives_final.json` | JSON：`id` + `narrative` |
| Topics（含子叙述） | `..._w_questions_w_sub_narratives_edit_20250822.json` | JSON |
| Qrels（文档相关性） | `trec.nist.gov/data/rag/2025-rag-qrels.txt` | TREC qrels，分级 0–4 |
| Qrels（nugget 级） | `github.com/castorini/trec25-rag` | 官方 nuggetizer |

**本地实测统计**：已下载的 `2025-rag-qrels.txt` 含 **22 个主题、10,284 条判定**，等级分布为 `{0: 3619, 1: 1499, 2: 3760, 3: 1318, 4: 88}`，平均每主题判定 467.5 条文档。官方可能分批发布，正式使用时须核对官方发布页与 overview 论文的口径与 MD5。

### 5.2 TREC Deep Learning Track（2021–2023）

虽已收官，仍是稠密检索最常用的官方测试集。qrels 与 topics 由 Anserini 官方维护副本发布。

| 用途 | 文件 | 记录数 | MD5 |
|---|---|---|---|
| DL21 qrels | `qrels.dl21-doc-msmarco-v2.1.txt` | 10,973 | `6845b6c128aec71027e72078a960600e` |
| DL22 qrels | `qrels.dl22-doc-msmarco-v2.1.txt` | 349,541 | `ac9f5c6fcb6972d8bf13b07ab150680a` |
| DL23 qrels | `qrels.dl23-doc-msmarco-v2.1.txt` | 15,995 | `4b30e8850b6fba56289b6c177afe959b` |
| Dev / Dev2 qrels | `qrels.msmarco-v2.1-doc.dev.txt` / `.dev2.txt` | 4,702 / 5,177 | `089b19dce...` / `8ff337f21...` |
| DL21/22/23 topics | `topics.dl21.txt` / `dl22.txt` / `dl23.txt` | 477 / 500 / 700 | `46d863434...` / `f1bfd53d8...` / `7df9e17b4...` |
| Dev / Dev2 topics | `topics.msmarco-v2-doc.dev.txt` / `.dev2.txt` | 4,552 / 5,000 | `b05dc19f1...` / `f000319f1...` |

DL23 的 700 条查询构成为 200 条人工真实查询 + 250 条 T5 合成 + 250 条 GPT-4 合成，官方刻意提高区分难度。

### 5.3 TREC 2024 RAG

| 文件 | 记录数 | MD5 |
|---|---|---|
| `qrels.rag24.test-umbrela-all.txt` | 108,479 | `7a43d4a23cf37f12dab0043a4b9f4d02` |
| `topics.rag24.test.txt` | 301 | `5bd6c8fa0e1300233fe139bae8288d09` |

官方公布的评测命令为 `trec_eval -c -m ndcg_cut.20`、`-m ndcg_cut.100`、`-m recall.100`。

### 5.4 数据格式规范（TREC 四件套）

| 件套 | 格式 | 说明 |
|---|---|---|
| Documents | 官方语料 | MS MARCO 等，需自行下载 |
| Topics | XML 或 JSON | 字段 title / desc / narrative |
| Qrels | `topic_id 0 doc_id relevance` | 第 2 列 `0` 为历史遗留占位列 |
| Run | `topic_id Q0 doc_id rank score run_tag` | 系统输出，6 列空白分隔 |

深度限制：TREC 2025 RAG 的 retrieval 子任务提交 Top-100，通用 ad-hoc 与 DL 通常为 1000。

---

## 第六章 评测指标

### 6.1 指标体系

| 指标 | 含义 | `trec_eval` 写法 | 适用场景 |
|---|---|---|---|
| **nDCG@k** | 折损累积增益归一化 | `-m ndcg_cut.10` | **主指标**，兼容二值与分级相关性 |
| MAP | 平均准确率均值 | `-m map` | 强调召回完整度 |
| MAP@k | 截断版 MAP | `-M 100 -m map` | 深度受限场景 |
| MRR | 首命中倒数排名 | `-m recip_rank` | 已知项检索、单答案 |
| Recall@k | 前 k 条召回率 | `-m recall.100,1000` | 候选池质量 |
| P@k | 前 k 条准确率 | `-m P.10` | 首屏精确度 |
| R-Precision | 在真实相关数处的准确率 | `-m Rprec` | 无需指定 k |
| bpref | 基于偏好关系的指标 | `-m bpref` | 判定不完整时 |
| infAP | 推断 AP | `-m infAP` | 判定不完整时的替代 |
| ERR | 期望倒数排名（级联模型） | `-m err` | 考虑用户浏览衰减 |
| judged_cut@k | Top-k 中被判定过的比例 | `-m judged_cut.10` | **诊断用**，非效果指标 |
| α-nDCG / ERR-IA / NRBP | 意图感知指标 | `ndeval` | 多样性、多意图查询 |

### 6.2 官方口径的三个开关

| 开关 | 作用 | 典型取值 |
|---|---|---|
| `-c` | 在 qrels 全量主题上平均，run 缺失的主题计 0 | 官方默认行为，必加 |
| `-l N` | 只有 `rel >= N` 视为相关 | DL 官方口径 N=2；RAG 2025 分级 0–4，常用 1 或 2 |
| `-M D` | 每主题只取前 D 条 | 100（RAG 提交）/ 1000（ad-hoc） |

`-l` 是最容易出错的一项。同一批 qrels，取 `-l 1` 与 `-l 2` 会得出完全不同的绝对数值，跨论文比较时必须确认口径一致。

### 6.3 指标选择建议

- **对外报告主指标报 nDCG@10**，辅以 Recall@100。二者组合有诊断价值：Recall@100 高而 nDCG@10 低，说明候选捞到了但排序错了，重排可救；Recall@100 低则重排无解。
- **同时报 judged_cut@10**。自建 run 命中大量未判定文档时，绝对数值不可与官方 run 横向比较，这个指标能提前暴露问题。

---

## 第七章 评测工具

### 7.1 NIST 官方工具

| 工具 | 语言 | 覆盖指标 | 获取 |
|---|---|---|---|
| **trec_eval** | C | map、ndcg_cut、P、recall、recip_rank、Rprec、bpref、iprec_at_recall、success、judged_cut、infAP、err、gm_map、set_* 系列 | `github.com/usnistgov/trec_eval`，`make` 编译 |
| **ndeval** | C | α-nDCG、ERR-IA、NRBP、α-DCG | `github.com/usnistgov/ndeval` |
| **gdeval** | — | nDCG′（分级相关性的严格实现） | 部分 TREC Web Track 采用 |

`trec_eval` 由 Chris Buckley 编写并长期维护，是事实标准。常用命令：

```bash
trec_eval -c -m ndcg_cut.10            -l 2 qrels.txt run.txt
trec_eval -c -M 100 -m map -m recip_rank -l 2 qrels.txt run.txt
trec_eval -c -m recall.100,1000        -l 2 qrels.txt run.txt
trec_eval -m all_trec qrels.txt run.txt          # 全指标
trec_eval -q -m ndcg_cut.10 qrels.txt run.txt    # 逐主题输出
```

### 7.2 社区等价实现

| 工具 | 说明 | 适用场景 |
|---|---|---|
| **pytrec_eval / pytrec_eval-terrier** | Python 绑定，**编译的是官方同一份 C 源码**，Anserini/Pyserini 官方回归测试使用 | 接入自己的 pipeline；本任务采用 |
| **ir-measures** | Terrier 团队维护，指标定义与官方一致，支持透传 trec_eval | 批量自动化评测 |
| **ranx** | 纯 Python，指标丰富 | 快速原型 |

### 7.3 各赛事官方 scorer

CLEF 各 lab、BioASQ（`bioasq-eval`，Java，算 MAP/F1/GM）、COLIEE、MS MARCO（`ms_marco_eval.py`，算 MRR@10）均提供自己的评测程序。**横向比较时必须使用官方版本**——第三方实现对并列分数、未标注文档等边界情况的处理不同，分数对不上。

### 7.4 本任务的工具选型

| 场景 | 选型 | 理由 |
|---|---|---|
| 沙箱/无 GitHub 环境 | `pytrec_eval-terrier` 0.5.10 | 数值等价官方，pip 可装 |
| 本机可编译环境 | 官方 `trec_eval` | 权威性最高，论文复现首选 |
| 提交前自检 | `check_format.py` | 覆盖官方硬性约束 + 两个语义坑 |
| 工具链自检 | `make_demo_run.py` + oracle run | 用已知预期值反证链路正确 |

---

## 第八章 交付成果与实测数据

### 8.1 成果清单

| 文件 | 作用 |
|---|---|
| `README.md` | 数据集清单、工具、口径、基线、坑位全表 |
| `tools/check_format.py` | 提交前格式与语义校验，退出码 0/1 |
| `tools/eval_official.py` | 指标计算（Python 路线），自动打印等价官方命令 |
| `tools/eval_official.sh` | 指标计算（官方 trec_eval 二进制路线） |
| `tools/make_demo_run.py` | 反造演示 run，自检工具链 |
| `data/2025-rag-qrels.txt` | 官方真实 qrels（22 主题 / 10,284 条） |
| `data/trec25_narratives_final.json` | 官方叙述型 topics |

### 8.2 三组对照实验实测

在真实官方 qrels 上运行，`-l 1 -M 100`：

| 演示 run | nDCG@10 | nDCG@100 | MRR | P@10 |
|---|---|---|---|---|
| oracle（完美排序） | **1.0000** | 1.0000 | 1.0000 | 1.0000 |
| shuffle（随机排序） | **0.4034** | 0.4783 | 0.7765 | 0.6273 |
| doclevel（粒度错配） | **0.0000** | 0.0000 | 0.0000 | 0.0000 |

oracle 得到 1.0000 证明工具链与口径配置无误；doclevel 全零证明粒度错配会导致指标完全失效且不报错。

### 8.3 基线参考值

**TREC DL 2023 passage（Anserini 官方回归）**

| 系统 | nDCG@10 | MAP@100 | MRR@100 | R@100 | R@1000 |
|---|---|---|---|---|---|
| BM25 | 0.2061 | 0.0751 | 0.3696 | 0.2365 | 0.4514 |
| SPLADE++ CoCondenser-SelfDistil | 0.4768 | 0.1963 | 0.6985 | 0.4137 | 0.6731 |
| SPLADE++ + Rocchio | 0.4774 | 0.2065 | 0.7100 | 0.4226 | 0.7056 |

**MS MARCO V2 doc dev（Pyserini BM25 基线）**：文档级 map 0.1552 / MRR 0.1572 / R@100 0.5956 / R@1000 0.8054；分段级 map 0.1875 / MRR 0.1896 / R@100 0.6555 / R@1000 0.8542。

跑出的数值远低于 BM25 基线时，应首先怀疑粒度错配与 `-l` 口径，而不是模型能力。

---

## 第九章 关键风险与建议

| 风险 | 表现 | 规避 |
|---|---|---|
| **粒度错配** | qrels 为 segment 级，系统按整篇检索，指标恒为 0 且不报错 | 用分段语料建索引；`check_format.py` [D] 项自动检查 |
| **未判定率过高** | 自造 run 大量命中 pooling 外文档 | 看 `judged_cut.10`；论文中如实声明不可与官方 run 横向比较 |
| **`-l` 口径不一致** | 同一 qrels 不同阈值数值差异巨大 | 对照当届 overview 论文；报告中显式注明 |
| **缺主题** | run 未覆盖全部主题 | 官方按全量主题平均，缺失计 0；用 `-c` 并跑校验器 [C] 项 |
| **表述错误** | 把 BEIR/MTEB 写成"官方评测" | 严格区分官方竞赛与民间 benchmark |
| **数据版本漂移** | MS MARCO 版本、qrels 分批发布 | 下载后核对 MD5 与记录数 |

**下一步建议**：若需正式参赛或复现，优先选择 TREC 2026 RAG（官方已在征集赛道提案与参赛注册）；若仅需方法学对标，TREC DL 2021–2023 因数据完整、基线齐全而更适合。

---

## 附录 A 参考资料

1. NIST, *The 34th Text REtrieval Conference TREC 2025*, NIST SP 1348, 2026-03.
2. Upadhyay S. et al., *Overview of the TREC 2025 Retrieval Augmented Generation (RAG) Track*, arXiv:2603.09891.
3. Thakur N. et al., *BEIR: A Heterogeneous Benchmark for Zero-shot Evaluation of Information Retrieval Models*, arXiv:2104.08663.
4. Upadhyay S. et al., *UMBRELA: UMbrela is the (Open-Source Reproduction of the) Bing RELevance Assessor*, arXiv:2406.06519.
5. Upadhyay S. et al., *A Large-Scale Study of Relevance Assessments with Large Language Models: An Initial Look*, arXiv:2411.08275；NIST 出版物，2025-07-18。
6. Harman D., *The Text REtrieval Conference (TREC)*，NTCIR 主题报告。
7. Manning C. et al., *Introduction to Information Retrieval*，标准测试集章节（Cranfield / TREC / NTCIR / CLEF 规模数据）。
8. TREC RAG 官方公告页：语料与 qrels 的 MD5 与记录数。
9. Anserini / Pyserini 官方回归文档：DL 各年基线数值与 `trec_eval` 命令。

## 附录 B 本地文件清单

```
/workspace/trec-eval-kit/
├── README.md
├── data/
│   ├── 2025-rag-qrels.txt           官方 TREC 2025 RAG qrels
│   ├── trec25_narratives_final.json 官方叙述型 topics
│   ├── run.oracle.txt / run.shuffle.txt / run.doclevel.txt
└── tools/
    ├── check_format.py
    ├── eval_official.py
    ├── eval_official.sh
    └── make_demo_run.py
```
