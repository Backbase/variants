## iOS Sample Project

### Version Control

The project is checked into git so it can be used while testing and developing `variants` features. However future changes have been suppressed using the following commands:

```
find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && pwd && git ls-files -z ${pwd} | xargs -0 git update-index --skip-worktree" \;
```

This can be undone by executing the following in this directory:

```
find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && pwd && git ls-files -z ${pwd} | xargs -0 git update-index --no-skip-worktree" \;
```

More information can be found at these Stackoverflow answers:

* https://stackoverflow.com/a/39776107/7264964
* https://stackoverflow.com/a/55860969/7264964

