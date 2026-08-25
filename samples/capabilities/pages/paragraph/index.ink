<script type="application/json" def>
{
  "navigationBarTitleText": "Paragraph"
}
</script>

<script setup>
export default {
  data: {
    jsCodeBlock: `const paragraph = compileInlineParagraph(source);
const preview = paragraph.runs.slice(0, 3);
return preview.map((run) => run.kind).join(', ');`,
    rustCodeBlock: `let paragraph = InlineParagraph::from_runs(runs);
renderer.draw_inline_paragraph(&paragraph, x, y, width);
renderer.draw_code_block(&code_block, x, y + 64.0, width);`,
  },
};
</script>

<page>
  <view class="page">
    <view class="hero">
      <text class="page-title">Paragraph</text>
      <text class="page-subtitle">
        A manual verification page for Markdown Foundation rendering, paragraph compilation, and
        snippet semantics.
      </text>
    </view>

    <view class="section-card">
      <text class="section-title">Paragraph</text>
      <p class="paragraph-block">
        This paragraph keeps
        <b>bold content</b>,
        <i>italic emphasis</i>, and inline code like
        <snippet>fetch()</snippet> inside one semantic paragraph flow.
      </p>
      <p class="paragraph-block">
        The goal is to make sure
        <snippet>paragraph.compile()</snippet> wraps with surrounding text instead of turning into
        separate flex children.
      </p>
    </view>

    <view class="section-card">
      <text class="section-title">Headings</text>
      <header level="1" class="heading heading-1">Heading Level 1</header>
      <p class="paragraph-block muted-copy">
        Large headers should remain block-level and preserve clear spacing before body content.
      </p>
      <header level="2" class="heading heading-2">Heading Level 2</header>
      <p class="paragraph-block muted-copy">
        Secondary headers still participate in the same vertical rhythm with nearby paragraphs.
      </p>
      <header level="3" class="heading heading-3">Heading Level 3</header>
    </view>

    <view class="section-card">
      <text class="section-title">Blockquote</text>
      <blockquote class="quote-block">
        Render block content with stable paragraph shaping, then keep inline code like
        <snippet>InlineKind::Code</snippet>
        inside the same readable quote.
      </blockquote>
    </view>

    <view class="section-card">
      <text class="section-title">Lists</text>
      <list class="list-block">
        <list-item class="list-item-block">
          Unordered list items should stack vertically and allow inline code such as
          <snippet>const value = 1</snippet>
          inside the item text.
        </list-item>
        <list-item class="list-item-block">
          List item layout should stay stable when the content wraps onto another line.
        </list-item>
      </list>
      <list class="list-block ordered-list">
        <list-item class="list-item-block">
          Ordered list examples reuse the same semantic node pair:
          <snippet>list</snippet>
          and
          <snippet>list-item</snippet>
          .
        </list-item>
        <list-item class="list-item-block">
          The second item helps verify spacing after multiple block-level siblings.
        </list-item>
      </list>
    </view>

    <view class="section-card">
      <text class="section-title">Inline Snippet</text>
      <p class="paragraph-block">
        Inline code should render as semantic code runs, so tokens like
        <snippet>const value = 1</snippet>
        and
        <snippet>paragraph.render()</snippet>
        remain readable inside normal prose.
      </p>
      <p class="paragraph-block">
        Another short sentence verifies that
        <snippet>CodeWrapMode::PreWrap</snippet>
        still flows as part of the surrounding paragraph.
      </p>
    </view>

    <view class="section-card">
      <text class="section-title">Code Block</text>
      <snippet class="code-block" style="display: block;" language="js">{{ jsCodeBlock }}</snippet>
      <snippet class="code-block" style="display: block;" language="rust">{{ rustCodeBlock }}</snippet>
    </view>

    <view class="section-card">
      <text class="section-title">Mixed Content</text>
      <p class="paragraph-block">
        Start with a normal paragraph, add
        <snippet>inline code</snippet>
        in the middle, then switch to a block snippet below.
      </p>
      <snippet class="code-block" style="display: block;" language="js">{{ jsCodeBlock }}</snippet>
      <p class="paragraph-block">
        The paragraph after the block code should still appear with clean spacing and a predictable
        reading order.
      </p>
    </view>
  </view>
</page>

<style>
.page {
  --paragraph-page-background: var(--color-background);
  --paragraph-surface-background: var(--color-surface);
  --paragraph-surface-muted-background: var(--color-surface-highlight);
  --paragraph-text-color: var(--color-text-primary);
  --paragraph-muted-text-color: var(--color-text-secondary);
  --paragraph-border-color: var(--border-color-default);
  --paragraph-accent-border: #d9e2f2;
  padding: var(--spacing-lg, 20px);
  display: flex;
  flex-direction: column;
  gap: var(--spacing-lg, 20px);
  background-color: var(--paragraph-page-background);
}

.hero {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.page-title {
  font-size: 28px;
  font-weight: 700;
  color: var(--paragraph-text-color);
}

.page-subtitle {
  font-size: 14px;
  line-height: 20px;
  color: var(--paragraph-muted-text-color);
}

.section-card {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: var(--spacing-md, 16px);
  border-radius: var(--radius-md, 12px);
  border: 1px solid var(--paragraph-border-color);
  background-color: var(--paragraph-surface-background);
}

.section-title {
  font-size: 13px;
  font-weight: 600;
  letter-spacing: 0.02em;
  color: var(--paragraph-muted-text-color);
}

.paragraph-block {
  display: block;
  font-size: 16px;
  line-height: 24px;
  color: var(--paragraph-text-color);
}

.muted-copy {
  color: var(--paragraph-muted-text-color);
}

.heading {
  display: block;
  color: var(--paragraph-text-color);
}

.heading-1 {
  font-size: 28px;
  line-height: 36px;
  font-weight: 700;
}

.heading-2 {
  font-size: 22px;
  line-height: 30px;
  font-weight: 700;
}

.heading-3 {
  font-size: 18px;
  line-height: 26px;
  font-weight: 600;
}

.quote-block {
  display: block;
  padding: 12px 14px;
  border-left: 3px solid var(--paragraph-accent-border);
  background-color: var(--paragraph-surface-muted-background);
  color: var(--paragraph-text-color);
  font-size: 15px;
  line-height: 23px;
}

.list-block {
  display: block;
  padding-left: 18px;
}

.ordered-list {
  padding-left: 22px;
}

.list-item-block {
  display: block;
  font-size: 15px;
  line-height: 23px;
  color: var(--paragraph-text-color);
}

.code-block {
  display: block;
  white-space: pre-wrap;
  font-size: 14px;
  line-height: 21px;
  color: var(--paragraph-text-color);
  background-color: var(--paragraph-surface-muted-background);
  border-radius: 10px;
  padding: 12px 14px;
}
</style>
