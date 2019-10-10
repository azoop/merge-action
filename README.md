# merge-action

Adds a `/merge $branch` command to pull request comments.

head: pull request's head branch
base: comment's branch

## Example Usage

```yaml
name: Merge
on: issue_comment
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - name: Automatic Merge
        uses: azoop/merge-action
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
