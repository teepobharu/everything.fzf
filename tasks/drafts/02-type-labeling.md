# Task: Implement Repository Type Labeling

**Priority:** LOW  
**Status:** Backlog  
**Created:** 2026-03-11  
**Assignee:** Future implementation

---

## Description

Add visual indicators to show repository type in the main fzf list: `[📁main]` for main repos, `[🔗worktree]` for worktrees, and `[📦submodule]` for submodules.

---

## Requirements

### Functional Requirements
1. Detect repository type for each scanned `.git` entry
2. Append type label to repository path in fzf list
3. Support three types:
   - **Main repo:** `.git` is a directory in repository root
   - **Worktree:** `.git` is a file containing `gitdir:` reference
   - **Submodule:** `.git` directory inside parent's `.git/modules/`

### Display Format
```
/path/to/main-repo [📁main]
/path/to/worktree [🔗worktree]
/path/to/submodule [📦submodule]
```

---

## Implementation Strategy

### Detection Logic

```bash
# For each .git path found:
git_path="$R/.git"

if [ -f "$git_path" ]; then
  # It's a file -> worktree
  type="[🔗worktree]"
elif [ -d "$git_path" ]; then
  # It's a directory -> check if submodule or main
  parent_git=$(git -C "$R" rev-parse --git-dir 2>/dev/null)
  if [[ "$parent_git" == *".git/modules/"* ]]; then
    type="[📦submodule]"
  else
    type="[📁main]"
  fi
else
  type="[❓unknown]"
fi
```

### Integration Points
1. Add detection after line ~202 (after .git directory scan)
2. Modify the output to include type label
3. Update preview to show type prominently
4. Enable via `GPROJ_INCLUDE_SUBMODULES=1` flag

---

## Performance Considerations

### Concerns
- Running `git rev-parse` for each repo could add significant time
- For 100 repos, could add 5-10 seconds

### Optimizations
1. **File type detection:** No git command needed (check if `.git` is file vs dir)
2. **Path-based submodule detection:** Check if path contains `.git/modules/`
3. **Parallel processing:** Use `xargs -P` for batch detection
4. **Caching:** Store type in cache along with repo path

### Recommended Approach
```bash
# Fast detection without git commands
if [ -f "$git_dir" ]; then
  echo "$repo_path [🔗worktree]"
elif [[ "$git_dir" == *".git/modules/"* ]]; then
  echo "$repo_path [📦submodule]"
else
  echo "$repo_path [📁main]"
fi
```

---

## Acceptance Criteria

- [ ] Type labels appear correctly for all three types
- [ ] Performance impact is <1s for 100 repositories
- [ ] Labels are visually distinct and use appropriate emojis
- [ ] Enabled via `GPROJ_INCLUDE_SUBMODULES=1` flag
- [ ] Works with caching system (cache invalidates on flag change)
- [ ] Preview shows type in header
- [ ] fzf filtering works with and without type labels

---

## Dependencies

- None (pure shell logic)
- Uses existing .git detection from main scanning logic

---

## Estimated Effort

**Time:** 3-6 hours  
**Complexity:** Medium

---

## Related Tasks

- See: `01-worktree-listing.md` (alt-w worktree selector)
- See: `03-depth-adjustment.md` (arrow key depth control)

---

## Notes

- Flag `GPROJ_INCLUDE_SUBMODULES` is already reserved (shows warning when used)
- Detection logic should NOT use git commands for performance
- Consider adding filter bindings (e.g., `ctrl-f` to toggle showing only main repos)
- Submodules in DOTFILES_DIR should be detected correctly
