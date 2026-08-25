const FULL_TEXT = `## Streaming Demo
This is a demonstration of **streamdown** component's streaming capabilities.

- **Fast** parsing with pulldown-cmark
- **Smooth** animations with Caret
- **Flexible** rendering of Markdown elements

Inline math streams with the text: $E = mc^2$.

$$\\int_0^1 x^2\\,dx = \\frac{1}{3}$$

\`\`\`javascript
function hello() {
  console.log("Hello, Streamdown!");
}
\`\`\`

Enjoy the streaming experience!`;

export default {
  data: {
    staticContent: '# Hello World\nThis is a **static** markdown content test.',
    streamingContent: '',
    isStreaming: false,
    complexContent: `### Markdown Elements
1. **Ordered**
2. *List*
3. ~~Items~~

> Blockquote test for ink-builtin-components.

---
Horizontal rule above.`,
    tableContent: `### Shared Table Rendering
The table below is parsed from standard Markdown syntax and rendered through the shared native \`table\` renderer.

| Name | Role | Score |
| :--- | :--: | ----: |
| **Alice** | Lead | 98 |
| Bob | \`QA\` | 87 |
| Charlie | Ops | 91 |

Aligned columns should stay intact, and inline formatting such as **bold** and \`code\` should remain visible inside table cells.`,
    formulaContent: `### Inline Formula
Einstein's mass-energy relation is $E = mc^2$, and the quadratic formula is $x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}$.

### Display Formula
$$\\frac{1}{2} + \\frac{1}{3} = \\frac{5}{6}$$

$$\\sum_{k=1}^{n} k = \\frac{n(n+1)}{2}$$

$$\\int_0^\\infty e^{-x}\\,dx = 1$$

### Delimiter Semantics
The price is \\$20, while \`$not_math$\` remains inline code.`,
    currentIndex: 0,
  },

  onLoad() {
    console.log('Streamdown test page loaded');
  },

  onUnload() {
    this.stopStreaming();
  },

  toggleStreaming() {
    if (this.data.isStreaming) {
      this.stopStreaming();
    } else {
      this.startStreaming();
    }
  },

  startStreaming() {
    this.setData({
      isStreaming: true,
      streamingContent: '',
      currentIndex: 0,
    });

    this.timer = setInterval(() => {
      const { currentIndex, streamingContent } = this.data;
      if (currentIndex < FULL_TEXT.length) {
        const nextChar = FULL_TEXT[currentIndex];
        this.setData({
          streamingContent: streamingContent + nextChar,
          currentIndex: currentIndex + 1,
        });
      } else {
        this.stopStreaming();
      }
    }, 50);
  },

  stopStreaming() {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
    this.setData({
      isStreaming: false,
    });
  },
};
