/**
 * Markdown formatter for Bats tests
 * Outputs test results in GitHub-flavored Markdown format
 */

const fs = require('fs');

// Constants for formatting
const PASS = '✅';
const FAIL = '❌';
const SKIP = '⏭️';

// Header for the Markdown report
function header() {
  const now = new Date();
  const dateStr = now.toISOString().split('T')[0];
  const timeStr = now.toTimeString().split(' ')[0];
  
  return `# Seatbelts Security Audit Report
  
*Generated on ${dateStr} at ${timeStr}*

This report contains results of automated security checks for your macOS system.

## Summary

`;
}

// Format a single test result
function formatTestResult(test, index) {
  const status = test.status === 0 ? PASS : (test.status === 2 ? SKIP : FAIL);
  const name = test.name.replace(/^\d+: /, '');
  let result = `### ${index}. ${name}\n\n**Status:** ${status} `;
  
  if (test.status === 0) {
    result += 'PASSED\n\n';
  } else if (test.status === 2) {
    result += 'SKIPPED\n\n';
    if (test.output) {
      result += `Reason: ${test.output.trim()}\n\n`;
    }
  } else {
    result += 'FAILED\n\n';
    if (test.output) {
      result += '```\n' + test.output.trim() + '\n```\n\n';
    }
  }
  
  return result;
}

// Group tests by file
function groupTestsByFile(tests) {
  const groups = {};
  
  tests.forEach(test => {
    const file = test.testFile.replace(/^.*\/tests\//, '').replace(/\.bats$/, '');
    if (!groups[file]) {
      groups[file] = [];
    }
    groups[file].push(test);
  });
  
  return groups;
}

// Format the entire report
module.exports = {
  formatHeader: function(header) {
    return '';
  },
  
  formatTest: function(test) {
    return '';
  },
  
  formatError: function(error) {
    return '';
  },
  
  formatSummary: function(stats) {
    let output = header();
    
    // Add overall statistics
    output += `* **Total Tests:** ${stats.total}\n`;
    output += `* **Passed:** ${stats.passed} ${PASS}\n`;
    output += `* **Failed:** ${stats.failed} ${FAIL}\n`;
    output += `* **Skipped:** ${stats.skipped} ${SKIP}\n\n`;
    
    // Group tests by file
    const groups = groupTestsByFile(stats.tests);
    
    // Format each group
    Object.keys(groups).forEach(file => {
      output += `## ${file.charAt(0).toUpperCase() + file.slice(1).replace(/_/g, ' ')}\n\n`;
      
      groups[file].forEach((test, index) => {
        output += formatTestResult(test, index + 1);
      });
    });
    
    // Add recommendations section if there are failures
    if (stats.failed > 0) {
      output += '## Recommendations\n\n';
      output += 'Please address the failed security checks above. Each failure represents a potential security risk.\n\n';
      output += 'For assistance, refer to the [Seatbelts documentation](https://startr.sh/Seatbelts).\n';
    }
    
    return output;
  }
};
