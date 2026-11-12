#!/bin/bash
# Usage: update_index.sh <tasks_output_file> <test_output_file>
TASKS_FILE=$1
TEST_FILE=$2
HTML_FILE="index.html"

esc() { sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }

# Extract the ToDo and Done sections and the test results
TODO=$(awk '/^ToDo Tasks:/{f=1;next} /^Done Tasks:/{f=0} f' "$TASKS_FILE" | esc)
DONE=$(awk '/^Done Tasks:/{f=1;next} f' "$TASKS_FILE" | esc)
TESTS=$(esc < "$TEST_FILE")

# Replace the content inside a <pre id="..."> tag
update_pre() {
  local id="$1" content="$2" file="$3"
  ID="$id" CONTENT="$content" perl -0pi -e 's|(<pre id="\Q$ENV{ID}\E">).*?(</pre>)|$1\n$ENV{CONTENT}\n$2|s' "$file"
}

update_pre "todo-tasks" "$TODO" "$HTML_FILE"
update_pre "done-tasks" "$DONE" "$HTML_FILE"
update_pre "test-results" "$TESTS" "$HTML_FILE"

# Commit and push the changes
git config --global user.name "github-actions[bot]"
git config --global user.email "github-actions[bot]@users.noreply.github.com"
git add "$HTML_FILE"
git diff --cached --quiet || git commit -m "Update index.html with task lists and test results"
git push origin main
