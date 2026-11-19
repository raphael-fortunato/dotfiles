---
name: feature-brainstorm
description: Generate and prioritize new product features based on user feedback and market trends. Use when brainstorming features, ideating improvements, or deciding what to build next.
---

# Feature Brainstorm

Generate new product feature ideas and analyze them for feasibility, impact, and priority.

## Quick Start

**Ideation workflow:**
```
User: "Come up with 5 new features for [product type]"
Agent: Generates features grounded in user feedback patterns and market trends
```

**Analysis workflow:**
```
User: "Prioritize these features: [list]"
Agent: Scores by feasibility, impact, effort, user demand
```

## Workflows

### 1. Feature Ideation

Generate novel features based on:
- **User feedback patterns**: Common requests, pain points, feature requests
- **Market trends**: Emerging capabilities, competitor innovations, user expectations
- **Product gaps**: Missing functionality compared to market leaders

**Workflow:**
1. Ask for product type/description
2. Ask about target users and their main pain points
3. Analyze what users typically request vs what exists
4. Generate 5-10 features at varying scope (quick-win to ambitious)
5. Present with brief rationale for each

**Checklist:**
- [ ] Features address identified user pain points
- [ ] Mix of incremental improvements and transformational ideas
- [ ] Feasibility ranges from quick-win to multi-sprint
- [ ] Each feature has clear user value

### 2. Feature Analysis

Evaluate and score features by:
- **Impact**: How many users benefit? How transformational?
- **Feasibility**: Implementation effort, technical risk
- **Demand**: User requests, market urgency
- **Effort**: Developer time, complexity, dependencies

**Workflow:**
1. Collect features to evaluate
2. Understand current product constraints (team size, tech stack, timeline)
3. Score each feature (1-5 scale)
4. Rank by priority score
5. Surface blockers or dependencies
6. Recommend quick wins and strategic bets

**Checklist:**
- [ ] Impact scored separately from effort (avoid conflating)
- [ ] Feasibility considers technical constraints
- [ ] Features ranked by (impact × demand) / effort
- [ ] Quick wins identified (high impact, low effort)
- [ ] Strategic bets identified (high impact, medium-high effort)

### 3. Combined Workflow

**For building a roadmap:**
1. Run ideation → get 8-10 feature candidates
2. Run analysis → score and rank
3. Identify quick wins for next sprint
4. Identify 2-3 strategic bets for quarters ahead
5. Highlight blockers or dependencies

## Advanced Features

See [REFERENCE.md](REFERENCE.md) for:
- Scoring rubric details and calibration
- User feedback analysis patterns
- Market trend research prompts
- Feature prioritization matrices

## Tips

- **Be specific about product type**: "Project management for distributed teams" vs generic "productivity app"
- **Define your users clearly**: Different user segments may have different feature priorities
- **Consider constraints**: A feature might be brilliant but low-priority if your team is 2 engineers
- **Validate with data**: Use actual user feedback, not assumptions
