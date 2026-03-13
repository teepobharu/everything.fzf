# gproj.fzf Changelog

All notable changes to this project will be documented in this file.

---

## [Unreleased]

### Planned Features
- alt-w binding for worktree listing (draft ready at lines 268-312)
- Dynamic depth adjustment with arrow keys
- Repository type labeling ([📁main]/[🔗worktree]/[📦submodule])

See `tasks/backlog/` for detailed specifications.

---

## [1.1.0] - 2026-03-12

### Added
- **Multiselect support** - Use TAB/SHIFT-TAB to select multiple repositories
  - `--multi` flag added to fzf invocations
  - Actions (ENTER, CTRL-V, CTRL-E) apply to highlighted item
  - CTRL-O outputs all selected items (useful for scripting)
  - Updated header to show "TAB=select"
  
- **Cache invalidation binding** - Press CTRL-R to refresh
  - Deletes cache file and rescans all roots
  - Shows fresh results immediately
  - Works in both tmux and non-tmux modes
  - Added RELOAD_SCRIPT for on-demand rescanning
  - Updated header to show "CTRL-R=refresh"

### Fixed
- **Worktree detection** - Now finds git worktrees properly
  - Removed `-t d` (type directory) from fd command
  - Removed `-type d` from find command
  - Now searches for both .git files (worktrees) AND directories (main repos)
  - Fixes missing results from `~/worktrees` and `~/.local/share/opencode/worktree`
  
### Changed
- Updated fd command documentation to reflect file+directory search
- Updated performance notes to include new benchmark data
- Updated header to prioritize new features (removed CTRL-O display to save space)

### Performance
- No performance regression
- Initial scan: ~4.5s (unchanged)
- Cache hit: <100ms (unchanged)
- Reload (CTRL-R): ~4.5s (same as initial scan)

### Files Modified
- `gproj.fzf` - Lines 176-195, 270-310, 366-369, 381, 389, 396, 403 (~60 lines changed)
- `tasks/QUICK_REFERENCE.md` - Updated with new features

### Test Results
```
✅ Help includes SUBMODULES flag
✅ Worktrees found (1 entry in ~/worktrees)
✅ Opencode repos found (3 entries)
✅ Multiselect enabled
✅ Ctrl-R reload binding found
✅ Header mentions CTRL-R and TAB
```

---

## [1.0.0] - 2026-03-11

### Added
- **Multi-root support**
  - Added `~/worktrees` to DEFAULT_ROOTS
  - Added `${DOTFILES_DIR:-$HOME/dotfiles}` to DEFAULT_ROOTS
  - Supports scanning git repositories with submodules
  
- **Reserved flags for future features**
  - `GPROJ_INCLUDE_SUBMODULES` flag (currently shows warning)
  - Reserved for future repository type labeling
  
- **Comprehensive documentation**
  - Added performance justification for fd command options
  - Documented --follow flag rationale (~0.5s overhead acceptable)
  - Added benchmark data comparing different fd approaches
  - Added future features TODO section in header comments
  
- **Task management system**
  - Created `tasks/` directory structure
  - Added three backlog tasks with detailed specifications:
    - `01-worktree-listing.md` - alt-w binding (HIGH priority)
    - `02-type-labeling.md` - repo type indicators (LOW priority)
    - `03-depth-adjustment.md` - dynamic depth control (MEDIUM priority)
  - Added `tasks/README.md` with workflow documentation
  - Added `tasks/QUICK_REFERENCE.md` for quick lookups
  
- **Draft implementation**
  - Prepared worktree listing script (commented out, lines 268-312)
  - Ready for future activation with alt-w binding
  - Includes nested fzf with actions (cd/lazygit/nvim/code)

### Changed
- Updated help text to include GPROJ_INCLUDE_SUBMODULES flag
- Enhanced header comments with feature roadmap
- Added inline comments explaining fd command choices

### Performance
- Maintained ~4.5s scan performance
- No regression from additional roots
- Cache system works with new roots

### Files Created
- `tasks/README.md`
- `tasks/QUICK_REFERENCE.md`
- `tasks/backlog/01-worktree-listing.md`
- `tasks/backlog/02-type-labeling.md`
- `tasks/backlog/03-depth-adjustment.md`

### Files Modified
- `gproj.fzf` - Lines 14-15, 9-27, 38-44, 48-52, 174-191 (~50 lines added)

---

## [0.9.0] - Prior to 2026-03-11

### Initial Features
- Git repository picker with fzf
- Cache system with configurable TTL
- Support for multiple search roots via EVERYTHING_FZF_ROOTS
- Ignore patterns via EVERYTHING_FZF_IGNORES
- tmux integration for seamless navigation
- Preview window with git status and recent commits
- Keybindings:
  - ENTER: cd to repository (in tmux)
  - CTRL-V: open in nvim
  - CTRL-E: open in code
  - CTRL-O: print path
  - ESC: cancel
- Debug mode with timing logs
- Configurable max depth
- Fallback to find when fd not available

---

## Migration Guide

### From 1.0.0 to 1.1.0

**No breaking changes!** All existing functionality preserved.

**New features you can use:**
1. Press TAB to select multiple repos, CTRL-O to output all
2. Press CTRL-R to refresh cache (no need to wait for TTL)
3. Worktrees in `~/worktrees` now appear in results

**If you experience issues:**
- Clear cache manually: `rm -rf ~/.cache/gproj/*`
- Run with debug: `GPROJ_DEBUG=1 ./gproj.fzf`
- Check worktree detection: `fd --hidden --follow -g '.git' ~/worktrees`

### From 0.9.0 to 1.0.0

**No breaking changes!** All existing functionality preserved.

**New features you can use:**
1. Set `DOTFILES_DIR` to override dotfiles location
2. Repos in `~/worktrees` are now scanned
3. Use `GPROJ_INCLUDE_SUBMODULES=1` to see future feature warning

**Cache invalidation recommended:**
```bash
rm -rf ~/.cache/gproj/*
```

---

## Links

- [Task Backlog](tasks/backlog/)
- [Quick Reference](tasks/QUICK_REFERENCE.md)
- [Task Management Guide](tasks/README.md)

---

## Notes

- Version numbers follow semantic versioning
- All changes maintain backward compatibility
- Performance benchmarks run on ~/AgodaGit with ~100 repos
- Test suite available at `/tmp/test_gproj.sh`
