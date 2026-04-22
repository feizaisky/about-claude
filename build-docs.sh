#!/usr/bin/env bash
# Regenerate outhtml/{cheatsheet,best-practices}.html from their Markdown sources.
# Usage: ./build-docs.sh
set -euo pipefail

cd "$(dirname "$0")"

generate() {
  local md="$1"
  local html="$2"
  local title="$3"

  {
    cat <<HEAD
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>${title}</title>
  <link rel="stylesheet" href="doc.css"/>
</head>
<body>
  <div class="layout">
    <nav class="sidebar">
      <a class="back" href="../index.html">← About Claude</a>
      <div class="sidebar-title">目录</div>
      <ul id="toc"></ul>
    </nav>
    <main class="main">
      <article id="content" class="article"><div class="loading">加载中…</div></article>
    </main>
  </div>

  <script id="md-content" type="text/markdown">
HEAD
    cat "$md"
    cat <<'TAIL'
</script>

  <script src="https://cdn.jsdelivr.net/npm/marked@12/marked.min.js"></script>
  <script>
    (function () {
      var mdEl = document.getElementById('md-content');
      var md = mdEl.textContent.replace(/^\s+/, '');
      marked.setOptions({ gfm: true, breaks: false });
      var article = document.getElementById('content');
      article.innerHTML = marked.parse(md);

      article.querySelectorAll('a[href]').forEach(function (a) {
        var href = a.getAttribute('href');
        if (!href) return;
        if (href.indexOf('claude-code-best-practices.md') !== -1) {
          href = href.replace('claude-code-best-practices.md', 'best-practices.html');
        } else if (href.indexOf('claude-code-cheatsheet.md') !== -1) {
          href = href.replace('claude-code-cheatsheet.md', 'cheatsheet.html');
        } else if (/(^|\/)README\.md($|#)/.test(href)) {
          href = '../index.html';
        }
        a.setAttribute('href', href);
      });

      function slugify(t) {
        return t.toLowerCase()
          .replace(/[^\w\u4e00-\u9fa5\s-]/g, '')
          .trim()
          .replace(/\s+/g, '-');
      }
      article.querySelectorAll('h1, h2, h3, h4').forEach(function (h) {
        if (!h.id) h.id = slugify(h.textContent);
      });

      var toc = document.getElementById('toc');
      var h2s = Array.prototype.slice.call(article.querySelectorAll('h2'))
        .filter(function (h) { return h.textContent.trim() !== '目录'; });
      h2s.forEach(function (h) {
        var li = document.createElement('li');
        var a = document.createElement('a');
        a.href = '#' + h.id;
        a.textContent = h.textContent;
        li.appendChild(a);
        toc.appendChild(li);
      });

      var tocLinks = toc.querySelectorAll('a');
      var headings = h2s;
      function sync() {
        if (!headings.length) return;
        var y = window.scrollY + 120;
        var idx = 0;
        for (var i = 0; i < headings.length; i++) {
          if (headings[i].offsetTop <= y) idx = i;
        }
        tocLinks.forEach(function (a, i) { a.classList.toggle('active', i === idx); });
      }
      window.addEventListener('scroll', sync, { passive: true });
      sync();

      var h1 = article.querySelector('h1');
      if (h1) document.title = h1.textContent.trim() + ' · About Claude';
    })();
  </script>
</body>
</html>
TAIL
  } > "$html"

  echo "✓ Generated $html ($(wc -c < "$html" | tr -d ' ') bytes)"
}

mkdir -p outhtml
generate "claude-code-cheatsheet.md"      "outhtml/cheatsheet.html"      "Claude Code 新手速查手册"
generate "claude-code-best-practices.md"  "outhtml/best-practices.html"  "Claude Code 日常使用最佳实践"
echo "Done."
