# Plans and Documentation

This directory contains planning documents for the Rod Crystal port project.

## Documents

### ROADMAP.md
The main development roadmap showing:
- Current project status (~5-8% complete)
- All 20 bd issues organized by priority (P0-P3)
- Phase-by-phase development plan
- Dependencies between features
- Success criteria and guidelines

**Each section in ROADMAP.md corresponds to a bd issue** with the format `rod-xxx: Title`

## Quick Links

- **View Available Work**: `bd ready`
- **Roadmap**: `docs/plans/ROADMAP.md`
- **Main README**: `README.md`

## Using bd with the Roadmap

### View All Issues
```bash
bd list
```

### See Available Work (Not In Progress)
```bash
bd ready
```

### View Specific Issue
```bash
bd show rod-6o3    # Element type
bd show rod-42c    # Query system
bd show rod-e1s    # JS Evaluation
```

### Claim an Issue
```bash
bd update rod-6o3 --status in_progress
```

### Complete an Issue
```bash
bd close rod-6o3
```

## Issue Priorities

Issues are organized by priority in the roadmap:

### P0 (Critical) - Start Here
These block other work and are core functionality:
- **rod-6o3**: Element type
- **rod-42c**: Query system  
- **rod-e1s**: JavaScript evaluation
- **rod-4nr**: Input types (Mouse, Keyboard, Touch)
- **rod-cqx**: Error types

### P1 (High) - Essential Features
- **rod-r6m**: Page navigation
- **rod-kz1**: Context/Timeout system
- **rod-edo**: Event system
- **rod-2sl**: Full Launcher
- **rod-d50**: Must helpers

### P2 (Medium) - Advanced Features
- **rod-1p6**: Hijack/Request interception
- **rod-pit**: Screenshots and PDF
- **rod-v79**: Device emulation
- **rod-94o**: Wait conditions
- **rod-9sa**: State management
- **rod-bot**: JavaScript helpers
- **rod-c6w**: Input keymap
- **rod-q20**: Utils library

### P3 (Low) - Nice-to-Have
- **rod-5wc**: Browser/Page pools
- **rod-dz0**: Development helpers

## Development Status

Check the current status of all issues:

```bash
# All open issues
bd list

# Only available (not in progress)
bd ready

# Summary
bd list | grep -c "open"     # Count open issues
bd list | grep -c "closed"   # Count closed issues
```

## Next Steps

1. **Read the roadmap**: `cat docs/plans/ROADMAP.md | less`
2. **Find available P0 work**: `bd ready | grep P0`
3. **Claim an issue**: `bd update <id> --status in_progress`
4. **Start coding!**

## Workflow Example

```bash
# Find work
bd ready
# Output shows: rod-6o3 [● P0] [task] - Implement Element type...

# Claim it
bd update rod-6o3 --status in_progress

# Create branch
git checkout -b feature/rod-6o3-element-type

# Implement feature with tests...

# Verify
crystal spec

# Commit
git commit -m "rod-6o3: Implement Element type with core DOM methods"

# Mark complete
bd close rod-6o3

# Push
git push origin feature/rod-6o3-element-type
```

## All Issue IDs

All 20 issues are tracked in bd:

**P0 (Critical)**:
rod-6o3, rod-42c, rod-e1s, rod-4nr, rod-cqx

**P1 (High)**:
rod-r6m, rod-kz1, rod-edo, rod-2sl, rod-d50

**P2 (Medium)**:
rod-1p6, rod-pit, rod-v79, rod-94o, rod-9sa, rod-bot, rod-c6w, rod-q20

**P3 (Low)**:
rod-5wc, rod-dz0

See ROADMAP.md for full details on each issue.
