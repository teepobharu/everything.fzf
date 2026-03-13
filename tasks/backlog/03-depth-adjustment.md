# Task: Implement Dynamic Depth Adjustment with Arrow Keys

**Priority:** MEDIUM  
**Status:** Backlog  
**Created:** 2026-03-11  
**Assignee:** Future implementation

---

## Description

Add interactive depth adjustment using arrow keys (similar to `$FZF_CTRL_T_OPTS`) to allow users to increase/decrease the search depth on-the-fly without restarting gproj.

---

## Requirements

### Functional Requirements
1. Bind `UP`/`DOWN` arrow keys to increase/decrease search depth
2. Show current depth in fzf header
3. Re-scan directories when depth changes
4. Preserve current selection if still in results
5. Provide visual feedback during re-scan

### User Experience
```
Initial state:
  Header: "gproj> [depth: 8] ENTER=cd | ↑↓=depth | ..."

After pressing ↑:
  Header: "gproj> [depth: 9] Scanning... | ENTER=cd | ↑↓=depth | ..."
  Results refresh with deeper scan

After pressing ↓:
  Header: "gproj> [depth: 7] Scanning... | ENTER=cd | ↑↓=depth | ..."
  Results refresh with shallower scan
```

---

## Implementation Strategy

### Approach 1: reload Binding (Recommended)
Use fzf's `reload` action to re-run the scan with updated depth:

```bash
# Create a scanner script that accepts depth parameter
read -r -d '' SCANNER_SCRIPT <<'SCANNER_EOF'
#!/usr/bin/env bash
DEPTH="$1"
shift
ROOTS=("$@")

for R in "${ROOTS[@]}"; do
  fd --hidden --follow --type d --max-depth "$DEPTH" -g '.git' "$R" 2>/dev/null
done | sed 's|/\.git/*$||' | sort -u
SCANNER_EOF

# Initial depth
CURRENT_DEPTH="${GPROJ_MAX_DEPTH:-8}"

# fzf with reload bindings
fzf \
  --header="[depth: $CURRENT_DEPTH] ↑=deeper ↓=shallower | ENTER=cd | ..." \
  --bind="up:reload(bash -c $(printf '%q' \"$SCANNER_SCRIPT\") $((CURRENT_DEPTH+1)) ${ROOTS[@]})" \
  --bind="down:reload(bash -c $(printf '%q' \"$SCANNER_SCRIPT\") $((CURRENT_DEPTH-1)) ${ROOTS[@]})"
```

### Approach 2: Execute + Restart (Alternative)
Use `execute` to update a state file and restart gproj:

```bash
--bind="up:execute(echo $((CURRENT_DEPTH+1)) > /tmp/gproj_depth)+abort"
```
Then check the state file on startup. (More complex, not recommended)

---

## Technical Challenges

### Challenge 1: Updating Header with New Depth
**Problem:** fzf header is static after initialization  
**Solution:** Use `reload` with `--header` that reads from a command:
```bash
--header="$(get_current_depth) | ENTER=cd | ..."
```

### Challenge 2: Performance During Re-scan
**Problem:** Re-scanning can take 4-5 seconds  
**Solution:** 
- Show "Scanning..." indicator in header
- Use `--bind 'load:...'` to show completion
- Consider showing cached results immediately while re-scanning

### Challenge 3: Depth Bounds
**Problem:** User could decrease to 0 or increase to 999  
**Solution:** Add bounds checking in scanner script:
```bash
MIN_DEPTH=1
MAX_DEPTH=20
DEPTH=$(( DEPTH < MIN_DEPTH ? MIN_DEPTH : DEPTH ))
DEPTH=$(( DEPTH > MAX_DEPTH ? MAX_DEPTH : DEPTH ))
```

---

## Acceptance Criteria

- [ ] Arrow keys increase/decrease depth by 1
- [ ] Header shows current depth value
- [ ] Results update after depth change
- [ ] Depth is bounded (min: 1, max: 20)
- [ ] Current selection is preserved if still in results
- [ ] Re-scan uses cache when applicable
- [ ] Visual feedback during re-scan ("Scanning..." indicator)
- [ ] Works in both tmux and non-tmux modes

---

## Dependencies

- `fzf` with `--reload` support (version 0.27.0+)
- Existing scanner logic (fd/find)
- Cache system integration

---

## Estimated Effort

**Time:** 4-8 hours  
**Complexity:** High

---

## Implementation Phases

### Phase 1: Basic Reload (2 hours)
- Create scanner script that accepts depth parameter
- Add simple reload bindings
- Test without cache

### Phase 2: Header Integration (2 hours)
- Update header to show current depth
- Add scanning indicator
- Test UI feedback

### Phase 3: Optimization (2 hours)
- Integrate with cache system
- Add depth bounds checking
- Performance testing

### Phase 4: Polish (2 hours)
- Preserve selection on reload
- Handle edge cases (empty results, etc.)
- Documentation

---

## Related Tasks

- See: `01-worktree-listing.md` (alt-w worktree selector)
- See: `02-type-labeling.md` (main/worktree/submodule indicators)

---

## Reference

Similar implementation in `fzf-file-widget` (CTRL-T):
```bash
FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'
  --bind 'ctrl-d:reload(fd --max-depth=$((FZF_CTRL_T_DEPTH+1)))'
"
```

---

## Notes

- This feature is inspired by `$FZF_CTRL_T_OPTS` depth adjustment
- Consider using `alt-up`/`alt-down` instead of arrow keys to avoid conflicts
- Could add `ctrl-r` to reset to default depth
- Future: Save preferred depth to config file
