# gproj.fzf Quick Reference

## Current Implementation (2026-03-12)

### New Root Directories
```bash
~/worktrees              # User worktree directories  
$DOTFILES_DIR            # Fallback: ~/dotfiles (includes submodules)
```

### New Features ✨
```bash
# Multiselect (2026-03-12)
TAB           # Select/deselect current item
SHIFT-TAB     # Deselect current item
CTRL-O        # Output all selected items

# Cache Refresh (2026-03-12)
CTRL-R        # Invalidate cache and rescan all roots

# Worktree Detection (2026-03-12)
# Now finds .git files (worktrees) AND directories (main repos)
# Previously only found directories, missing worktrees!
```

### Reserved Flags
```bash
GPROJ_INCLUDE_SUBMODULES=1    # Prints warning, reserved for type labeling
```

### Performance Benchmarks
```bash
fd -H -g '\.git' -t d         # ~4.0s (old - dirs only)
fd -H --follow -g '\.git'     # ~4.5s (current - files & dirs, finds worktrees!)
```

---

## Future Features (Backlog)

### 1. Worktree Listing (HIGH Priority)
```bash
# Trigger: Press alt-w on selected repo
# Opens nested fzf with:
#   - List of worktrees: /path/to/worktree [🔗branch]
#   - Actions: enter=cd, ctrl-l=lazygit, ctrl-v=nvim, ctrl-e=code

# Draft code location: gproj.fzf:268-312 (commented)
```

### 2. Type Labeling (LOW Priority)
```bash
# Show repo type in list:
/path/to/repo [📁main]        # Main repository
/path/to/repo [🔗worktree]    # Git worktree
/path/to/repo [📦submodule]   # Git submodule

# Enable with: GPROJ_INCLUDE_SUBMODULES=1
```

### 3. Depth Adjustment (MEDIUM Priority)
```bash
# Dynamic depth control:
↑ arrow key    # Increase depth, re-scan
↓ arrow key    # Decrease depth, re-scan

# Header shows: [depth: 8] ↑↓=adjust
```

---

## Quick Commands

### Testing
```bash
# Show help with new flag
./gproj.fzf --help

# Test warning message
GPROJ_INCLUDE_SUBMODULES=1 ./gproj.fzf

# Debug mode with new roots
GPROJ_DEBUG=1 GPROJ_CACHE=0 ./gproj.fzf
```

### Task Management
```bash
# View backlog
ls tasks/backlog/

# Move task to pending
mv tasks/backlog/01-worktree-listing.md tasks/pending/

# Start working on task
mv tasks/pending/01-worktree-listing.md tasks/in_progress/

# Complete task
mv tasks/in_progress/01-worktree-listing.md tasks/completed/
```

---

## File Locations

| Item | Location |
|------|----------|
| Main script | `gproj.fzf` |
| Config roots | Line 29 |
| Reserved flags | Line 38 |
| fd justification | Lines 174-191 |
| Draft worktree code | Lines 268-312 |
| Task backlog | `tasks/backlog/` |
| Task README | `tasks/README.md` |

---

## Environment Variables Reference

| Variable | Default | Purpose |
|----------|---------|---------|
| `GPROJ_DEBUG` | 0 | Enable timing logs |
| `GPROJ_MAX_DEPTH` | 8 | Max search depth |
| `GPROJ_CACHE` | 1 | Enable caching |
| `GPROJ_CACHE_TTL` | 1800 | Cache seconds |
| `GPROJ_INCLUDE_SUBMODULES` | 0 | Reserved for type labeling |
| `DOTFILES_DIR` | ~/dotfiles | Dotfiles location |

---

## Next Implementation Priority

1. **alt-w worktree listing** (2-4h) - HIGH
2. **Arrow key depth adjustment** (4-8h) - MEDIUM  
3. **Type labeling** (3-6h) - LOW

---

## Notes

- All changes are backward compatible
- No breaking changes
- Draft code ready for worktree listing
- Performance maintained at ~4.5s
