const { DateTime } = require("luxon");
const pluginRss = require("@11ty/eleventy-plugin-rss");
const pluginSyntaxHighlight = require("@11ty/eleventy-plugin-syntaxhighlight");
const pluginBundle = require("@11ty/eleventy-plugin-bundle");
const pluginNavigation = require("@11ty/eleventy-navigation");
const { EleventyHtmlBasePlugin } = require("@11ty/eleventy");
const sectionizePlugin = require("./_plugins/eleventy-plugin-sectionize");

module.exports = function(eleventyConfig) {
  eleventyConfig.addPassthroughCopy({
    "./assets/": "/",
  });
  // Copy any image file to `_site`, via Glob pattern
	// Keeps the same directory structure.
	eleventyConfig.addPassthroughCopy("**/*.{png,jpg,jpeg,gif,svg}");

  // passthrough any sh files
  eleventyConfig.addPassthroughCopy("**/*.sh");
  // _passthrough _redirects
  eleventyConfig.addPassthroughCopy("_redirects");

  //have specifically md files use the default.njk layout


  return {
    dir: {
      input: ".",
      includes: "_includes",
      data: "_data",
    },
    markdownTemplateEngine: "liquid",
    htmlTemplateEngine: "njk",
  };
};
