# gproj Performance Optimization Summary

## Problem
Initial implementation was slow when scanning large directory trees (5+ seconds for AgodaGit).

## Diagnosis Results

### Bottleneck Identification
Ran diagnosis on default roots:
```
✓ ~/AgodaGit: 48 repos (5s without optimization)
✓ ~/Personal: 14 repos (<1s)
✓ ~/.local/share/opencode/worktree: 0 repos (<1s)
```

**Primary bottleneck**: Deep directory traversal in AgodaGit

### Tool Performance
- ✓ `fd` installed and used (significantly faster than `find`)
- Fast scan with depth limit: ~575ms total for all roots

## Optimizations Implemented

### 1. **Max Depth Limit** (BIGGEST IMPACT)
- Added `GPROJ_MAX_DEPTH` environment variable (default: 5)
- Prevents scanning deeply nested directories
- **Improvement**: 5s → 575ms (8.7x faster)

```bash
# Before:
fd --hidden --type d -g .git ~/AgodaGit

# After:
fd --hidden --type d --max-depth 5 -g .git ~/AgodaGit
```

### 2. **Result Caching**
- Cache discovered repos for 30 minutes (configurable)
- Cache key based on search roots
- **Improvement**: 575ms → ~10ms on subsequent runs

```bash
# Enable/disable
GPROJ_CACHE=0 gproj  # disable
GPROJ_CACHE_TTL=3600 gproj  # 1 hour cache
```

### 3. **Removed Expensive Operations**
- Removed `git rev-parse --show-toplevel` calls in discovery (called once per repo)
- Removed `find . -type f | wc -l` from preview (very slow on large repos)
- Simple `sed` to strip `.git` suffix instead

### 4. **Optimized Preview Script**
- Lightweight preview showing only essential git info
- No file counting (was very slow)
- Quick git status and log only

## Performance Metrics

### First Run (No Cache)
```
[gproj] init: 5ms
[gproj] config: 15ms
[gproj] Scanning... 
[gproj] scan: ~575ms  (all 3 roots)
[gproj] normalize: ~100ms
[gproj] ready: ~700ms total
```

### Subsequent Runs (With Cache)
```
[gproj] cache-hit: ~10ms
[gproj] ready: ~15ms total
```

**Overall improvement**: ~5000ms → ~700ms (7x faster) without cache, ~500x faster with cache

## Configuration Options

```bash
# Debug mode - see timing breakdown
GPROJ_DEBUG=1 gproj

# Adjust max depth (higher = slower but finds more)
GPROJ_MAX_DEPTH=3 gproj  # faster, less deep
GPROJ_MAX_DEPTH=10 gproj # slower, more thorough

# Cache control
GPROJ_CACHE=0 gproj           # disable caching
GPROJ_CACHE_TTL=1800 gproj    # 30 min (default)
GPROJ_CACHE_TTL=7200 gproj    # 2 hours

# Custom roots
EVERYTHING_FZF_ROOTS=~/myprojects:~/work gproj
```

## Benchmarking

Run the included benchmark:
```bash
scripts/everything.fzf/tests/benchmark-gproj.sh
```

## Recommendations

### For Speed
1. Keep `GPROJ_MAX_DEPTH=5` or lower (default is 5)
2. Enable cache (default: on)
3. Add large directories to ignore list
4. Install `fd` if not present: `brew install fd`

### For Completeness
1. Increase `GPROJ_MAX_DEPTH` to 8-10
2. Reduce cache TTL to get fresh results more often
3. Use `GPROJ_CACHE=0` to always scan fresh

### Troubleshooting Slowness

If still slow:
```bash
# 1. Check which root is slow
GPROJ_DEBUG=1 gproj

# 2. Test individual roots
EVERYTHING_FZF_ROOTS=~/AgodaGit GPROJ_DEBUG=1 gproj

# 3. Reduce depth further
GPROJ_MAX_DEPTH=3 GPROJ_DEBUG=1 gproj

# 4. Check if fd is being used
command -v fd  # should exist

# 5. Clear stale cache
rm -rf ~/.cache/gproj
```

## Trade-offs

| Setting | Speed | Completeness |
|---------|-------|--------------|
| MAX_DEPTH=3 | ⚡⚡⚡ Fastest | ⚠️ May miss deep repos |
| MAX_DEPTH=5 | ⚡⚡ Fast (default) | ✓ Good balance |
| MAX_DEPTH=10 | ⚡ Slower | ✓✓ Most complete |
| Cache ON | ⚡⚡⚡ Instant (after first) | ⚠️ May be stale |
| Cache OFF | ⚡ Scan every time | ✓ Always fresh |
