# Task: Implement alt-w Worktree Listing

**Priority:** HIGH  
**Status:** Backlog  
**Created:** 2026-03-11  
**Assignee:** Future implementation

---

## Description

Add `alt-w` keybinding to list all worktrees for the currently highlighted git repository in a nested fzf interface with quick actions.

---

## Requirements

### Functional Requirements
1. Detect when user presses `alt-w` on a selected repository
2. Check if the repository has worktrees (via `git worktree list`)
3. Launch nested fzf showing all worktrees with branch names
4. Provide action bindings in nested fzf:
   - `ENTER`: Navigate to worktree
   - `CTRL-L`: Open lazygit in worktree
   - `CTRL-V`: Open nvim in worktree
   - `CTRL-E`: Open code in worktree
   - `ESC`: Cancel and return

### Technical Requirements
1. Use `git worktree list --porcelain` for reliable parsing
2. Format display as: `/path/to/worktree [🔗branch-name]`
3. Show preview with `git status --short` for selected worktree
4. Handle edge cases:
   - No worktrees (show message)
   - Detached HEAD worktrees
   - Main repo in worktree list

---

## Implementation Notes

### Draft Code Location
- **File:** `gproj.fzf`
- **Lines:** ~268-312 (commented out section)
- **Variable:** `WORKTREE_SCRIPT`

### Key Commands
```bash
# List worktrees
git worktree list --porcelain

# Parse output with awk to extract path and branch
# Format: worktree /path/to/worktree
#         HEAD <sha>
#         branch refs/heads/<branch-name>
#         <blank line>
```

### Integration Points
1. Add binding to tmux section (line ~283):
   ```bash
   --bind="alt-w:execute(bash -c $(printf '%q' "$WORKTREE_SCRIPT") -- {} $CURRENT_PANE)"
   ```
2. Add binding to non-tmux section (line ~290) with appropriate fallback
3. Update HEADER to include `ALT-W=worktrees`

---

## Acceptance Criteria

- [ ] Pressing `alt-w` opens worktree selector for highlighted repo
- [ ] Nested fzf shows all worktrees with `[🔗branch]` format
- [ ] All 4 action bindings work correctly in tmux
- [ ] Error message shown if no worktrees exist
- [ ] Preview shows git status for selected worktree
- [ ] Works in both tmux and non-tmux environments
- [ ] Performance: Worktree list loads in <500ms for repos with <50 worktrees

---

## Dependencies

- `git` (version 2.5+ for worktree support)
- `fzf`
- `tmux` (for send-keys functionality)
- Optional: `lazygit` (for ctrl-l binding)

---

## Estimated Effort

**Time:** 2-4 hours  
**Complexity:** Medium

---

## Related Tasks

- See: `02-type-labeling.md` (main/worktree/submodule indicators)
- See: `03-depth-adjustment.md` (arrow key depth control)

---

## Notes

- The draft implementation is already prepared in the source file
- Main work is testing and integration
- Consider adding worktree count to main repo preview
- Future: Detect main repo vs worktree and show indicator in main list
