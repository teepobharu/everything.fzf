# gproj.fzf Tasks

Task management directory for tracking gproj.fzf development and enhancements.

---

## Directory Structure

```
tasks/
├── README.md           # This file
├── backlog/            # Future features and enhancements
│   ├── 01-worktree-listing.md
│   ├── 02-type-labeling.md
│   └── 03-depth-adjustment.md
├── pending/            # Approved tasks ready to start
├── in_progress/        # Currently being worked on
└── completed/          # Finished tasks (archive)
```

---

## Task Status Workflow

```
backlog → pending → wip → completed
    ↓                                 ↑
  [rejected/cancelled] ←──────────────┘
```

### Status Definitions

- **backlog**: Future features, nice-to-haves, not yet prioritized
- **pending**: Approved and prioritized, ready to be picked up
- **in_progress**: Currently being implemented
- **completed**: Finished, merged, and verified

---

## Task Priority Levels

| Priority   | Description                      | SLA          |
| ---------- | -------------------------------- | ------------ |
| **HIGH**   | Critical features or urgent bugs | Work on ASAP |
| **MEDIUM** | Important enhancements           | Next sprint  |
| **LOW**    | Nice-to-have improvements        | Backlog      |

---

## Current Roadmap

### High Priority

1. **Worktree Listing** (`01-worktree-listing.md`)
   - alt-w binding to list worktrees with actions
   - Draft code already prepared
   - Estimated: 2-4 hours

### Medium Priority

2. **Depth Adjustment** (`03-depth-adjustment.md`)
   - Arrow keys to adjust search depth dynamically
   - Requires fzf reload integration
   - Estimated: 4-8 hours

### Low Priority

3. **Type Labeling** (`02-type-labeling.md`)
   - Show [📁main]/[🔗worktree]/[📦submodule] indicators
   - Requires `GPROJ_INCLUDE_SUBMODULES=1` implementation
   - Estimated: 3-6 hours

---

## Completed Enhancements (2026-03-11)

### ✅ Multi-Root Support

- Added `~/worktrees` to DEFAULT_ROOTS
- Added `$DOTFILES_DIR` with fallback to `~/dotfiles`
- Submodules in DOTFILES_DIR are now included

### ✅ Performance Justification

- Documented fd command options rationale
- Benchmarked `--follow` flag (~0.5s overhead)
- Added inline comments explaining tradeoffs

### ✅ Reserved Flags

- Added `GPROJ_INCLUDE_SUBMODULES=1` flag (reserved for future use)
- Prints warning when used (not yet implemented)

### ✅ Draft Implementation

- Prepared alt-w worktree listing script (commented out)
- Ready for integration when prioritized

### ✅ Documentation

- Updated header comments with future features
- Added comprehensive help text
- Created this task management system

---

## Task Template

When creating new tasks, use this template:

```markdown
# Task: [Title]

**Priority:** HIGH|MEDIUM|LOW  
**Status:** Backlog|Pending|In Progress|Completed  
**Created:** YYYY-MM-DD  
**Assignee:** Name or "Future implementation"

---

## Description

Brief description of the task/feature.

---

## Requirements

### Functional Requirements

- [ ] Requirement 1
- [ ] Requirement 2

### Technical Requirements

- [ ] Requirement 1
- [ ] Requirement 2

---

## Implementation Notes

Technical details, approaches, code snippets.

---

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2

---

## Dependencies

List any dependencies or prerequisites.

---

## Estimated Effort

**Time:** X-Y hours  
**Complexity:** Low|Medium|High

---

## Related Tasks

Links to related task files.

---

## Notes

Additional context, references, etc.
```

---

## Contributing

### Moving Tasks Between States

```bash
# Move task to pending (ready to work)
mv tasks/backlog/01-worktree-listing.md tasks/pending/

# Mark as in progress
mv tasks/pending/01-worktree-listing.md tasks/in_progress/

# Complete task
mv tasks/in_progress/01-worktree-listing.md tasks/completed/
```

### Updating Task Status

Edit the task file's header:

```markdown
**Status:** In Progress  
**Started:** 2026-03-11  
**Assignee:** Your Name
```

---

## Quick Links

- **Main Script:** `../gproj.fzf`
- **Draft Code:** Lines ~268-312 in `gproj.fzf` (worktree listing)
- **Performance Benchmarks:** Lines ~174-191 in `gproj.fzf` (fd justification)

---

## Notes

- Tasks are sorted by priority within each status directory
- Use numeric prefixes (01-, 02-, etc.) to maintain order
- Archive completed tasks older than 6 months
- Link related tasks using relative paths
