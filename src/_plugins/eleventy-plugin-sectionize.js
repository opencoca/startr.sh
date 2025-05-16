const markdownIt = require("markdown-it");
const markdownItAnchor = require("markdown-it-anchor");
const markdownItAttrs = require("markdown-it-attrs");
const fs = require('fs');
const matter = require('gray-matter');

function configureMarkdown(permalinksEnabled = false) {
  // Configure markdown-it-attrs with explicit image support
  const md = markdownIt({ html: true }).use(markdownItAttrs, {
    allowedAttributes: ['id', 'class', 'style'],
    leftDelimiter: '{',
    rightDelimiter: '}',
    // Make sure to include image processing
    enableAttrImageFlag: true
  });

  if (permalinksEnabled) {
    md.use(markdownItAnchor, {
      permalink: true,
      permalinkClass: 'header-anchor',
      permalinkSymbol: '🔗',
      permalinkBefore: true,
      slugify: s => s.toLowerCase().replace(/[^\w]+/g, '-')
    });
  }

  function wrapSections(tokens) {
    let result = [];
    let stack = [];
    let lastLevel = 0;
    let sectionAttrs = '';
    let pendingSectionAttrs = '';
    let pendingImageAttrs = '';

    tokens.forEach((token, index) => {
      // Handle general attribute blocks
      if (token.type === 'inline' && token.content.startsWith('{') && token.content.endsWith('}')) {
        // This token is an attribute block, extract and store the attributes
        pendingSectionAttrs = token.content.slice(1, -1);
        // Skip adding this token to the result as it's not a part of the actual content
        return;
      }

      // Special handling for image attributes
      if (token.type === 'inline' && token.children) {
        // Look for image tokens followed by attribute blocks
        for (let i = 0; i < token.children.length - 1; i++) {
          const child = token.children[i];
          const nextChild = token.children[i + 1];
          
          if (child.type === 'image' && nextChild.type === 'text' && 
              nextChild.content.trim().startsWith('{') && nextChild.content.trim().endsWith('}')) {
            // Extract attributes from the text token
            const attrs = nextChild.content.trim().slice(1, -1);
            
            // Apply attributes directly to the image token
            if (!child.attrs) child.attrs = [];
            
            // Parse the style attribute and add to image
            const styleMatch = attrs.match(/style="([^"]*)"/);
            if (styleMatch && styleMatch[1]) {
              child.attrs.push(['style', styleMatch[1]]);
              
              // Remove the attribute block from the text token
              nextChild.content = nextChild.content.replace(/{[^}]*}/, '');
            }
          }
        }
      }

      if (token.type === 'heading_open') {
        let level = parseInt(token.tag.slice(1));

        while (stack.length && lastLevel >= level) {
          result.push(stack.pop());
          lastLevel--;
        }

        // Use pendingSectionAttrs if available, otherwise use sectionAttrs
        sectionAttrs = pendingSectionAttrs || sectionAttrs;
        result.push({ type: 'html_block', content: `<section ${sectionAttrs}>` });
        stack.push({ type: 'html_block', content: '</section>' });
        lastLevel = level;
        sectionAttrs = ''; // Reset attributes after using them
        pendingSectionAttrs = ''; // Reset pending attributes
      }

      // Check if the current token is an empty paragraph and skip it if true
      if (token.type === 'paragraph_open') {
        const nextToken = tokens[index + 1];
        const closingToken = tokens[index + 2];
        if (
          nextToken.type === 'inline' &&
          (nextToken.content.trim() === '' || nextToken.content.startsWith('{') && nextToken.content.endsWith('}')) &&
          closingToken.type === 'paragraph_close'
        ) {
          // Skip the paragraph_open, inline (empty or attributes only), and paragraph_close tokens
          return;
        }
      }

      result.push(token);
    });

    while (stack.length) {
      result.push(stack.pop());
    }

    return result;
  }

  md.core.ruler.push('wrap_sections', state => {
    state.tokens = wrapSections(state.tokens);
  });

  return md;
}

module.exports = function(eleventyConfig) {
  eleventyConfig.addFilter("markdown", function(content, outputPath) {
    if (!outputPath || !outputPath.endsWith(".html")) {
      return content;
    }

    const inputPath = this.page.inputPath;
    const fileContent = fs.readFileSync(inputPath, 'utf8');
    const data = matter(fileContent).data;
    const permalinksEnabled = data.permalinks === true;

    const md = configureMarkdown(permalinksEnabled);
    return md.render(content);
  });

  // Set the default Markdown library without permalinks
  eleventyConfig.setLibrary("md", configureMarkdown(false));
};
