#!/usr/bin/env bash
# 把调研主页同步到 GitHub Pages
# 用法：在解压后的目录里执行  bash push-to-github.sh
# 目标地址：https://jxzhen.github.io/SearchEngine.html

set -e

GITHUB_USER="jxzhen"
REPO_NAME="jxzhen.github.io"          # 特殊命名，Pages 会自动开启
REPO_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

echo "==================================================="
echo " 目标仓库：${REPO_URL}"
echo " 最终访问：https://${GITHUB_USER}.github.io/SearchEngine.html"
echo "==================================================="
echo

# ---------- 1. 检查 git ----------
if ! command -v git >/dev/null 2>&1; then
  echo "[错误] 未找到 git，请先安装："
  echo "  Windows : https://git-scm.com/download/win"
  echo "  macOS   : brew install git  或  xcode-select --install"
  exit 1
fi
echo "[1/5] git 已就绪：$(git --version)"

# ---------- 2. 初始化本地仓库 ----------
if [ ! -d .git ]; then
  git init -q
  echo "[2/5] 已初始化本地仓库"
else
  echo "[2/5] 本地仓库已存在，跳过初始化"
fi
git config user.email "${GITHUB_USER}@users.noreply.github.com"
git config user.name  "${GITHUB_USER}"

# ---------- 3. 提交 ----------
git add -A
if git diff --cached --quiet; then
  echo "[3/5] 无新增改动"
else
  git commit -q -m "Sync evaluation campaign research overview (Task 1/2/3)"
  echo "[3/5] 已提交"
fi

# ---------- 4. 关联远程并推送 ----------
git branch -M main
if git remote | grep -q origin; then
  git remote set-url origin "${REPO_URL}"
else
  git remote add origin "${REPO_URL}"
fi
echo "[4/5] 正在推送（如提示输入凭据：用户名填 ${GITHUB_USER}，密码粘贴 Personal Access Token）"
git push -u origin main

# ---------- 5. 收尾提示 ----------
echo "[5/5] 推送完成"
echo
cat <<'TIP'
---------------------------------------------------
接下来（只需做一次）：

  1. 打开 https://github.com/jxzhen/jxzhen.github.io/settings/pages
  2. Source 选择 "Deploy from a branch"
  3. Branch 选 main，目录选 / (root)，点 Save
  4. 等 1~2 分钟，访问：
     https://jxzhen.github.io/SearchEngine.html

说明：
  * 仓库名必须是 jxzhen.github.io 这种形式；若用其它名字，
    地址会变成 https://jxzhen.github.io/<仓库名>/SearchEngine.html
  * 目录里的 .nojekyll 是必需的，不要删，否则 downloads/ 下的
    下划线开头文件可能被 Jekyll 忽略
  * 单文件需小于 100 MB，当前最大的 PDF 约 1.1 MB，没问题
---------------------------------------------------
TIP
