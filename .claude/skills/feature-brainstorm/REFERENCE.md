# Feature Brainstorm - Reference

## Scoring Rubric

### Impact Scoring (1-5)

- **1 (Minimal)**: Affects <5% of users or very niche use case
- **2 (Low)**: Affects 5-20% of users; nice-to-have improvement
- **3 (Medium)**: Affects 20-50% of users; meaningful improvement
- **4 (High)**: Affects 50%+ of users; solves significant pain point
- **5 (Transformational)**: Core product value; defines market position

### Feasibility Scoring (1-5)

- **1 (High Risk)**: New tech/domain, architectural changes, high uncertainty
- **2 (Medium-High Risk)**: Requires new expertise, moderate scope, some unknowns
- **3 (Medium)**: Clear requirements, moderate complexity, buildable with current stack
- **4 (Low Risk)**: Straightforward, uses existing patterns, well-understood scope
- **5 (Trivial)**: Configuration or minor addition to existing feature

### Effort Scoring (1-5)

- **1**: Can ship in 1-2 days (quick win)
- **2**: Can ship in 1-2 weeks (small feature)
- **3**: 3-4 weeks (medium feature)
- **4**: 1-3 months (major feature)
- **5**: 3+ months (epic-scale work)

### Demand Scoring (1-5)

- **1 (Low)**: No user requests, emerging trend
- **2 (Below Average)**: Occasional requests, some competitive pressure
- **3 (Average)**: Regular requests, matched by competitors
- **4 (High)**: Frequently requested, competitive gap
- **5 (Critical)**: Top user request, major competitive vulnerability

## Priority Calculation

**Raw Priority Score** = (Impact + Demand) × Feasibility / Effort

- Score > 3: High priority (do soon)
- Score 1.5-3: Medium priority (roadmap candidates)
- Score < 1.5: Low priority or future consideration

**Quick Wins** = (Impact ≥ 3 AND Effort ≤ 2) → Do immediately

**Strategic Bets** = (Impact ≥ 4 AND Effort ≥ 3) → Plan for quarters ahead

## User Feedback Analysis Patterns

### Common Pain Points to Look For

- Repetitive manual work → Automation opportunities
- Data silos → Integration features
- Complex workflows → UI/UX improvements
- Feature requests from diverse users → Common need signal
- Feature requests from power users → Differentiation opportunity
- Complaints about competitors → Competitive feature gaps

### Feedback Sources

1. **Direct**: Support tickets, feedback surveys, user interviews
2. **Behavioral**: Usage analytics, feature adoption, churn signals
3. **Market**: Competitor feature announcements, industry reports
4. **Community**: Discussions, forums, review sites (G2, Capterra, etc.)

### Red Flags for Feature Ideas

- Requested by single user or very small cohort
- Niche use case without broader applicability
- Contradicts core product vision
- High effort for low impact
- Requires architectural overhaul
- Out of scope for near-term roadmap

## Market Trend Research

### Emerging Trends to Track

- **AI/ML**: Automation, personalization, predictive capabilities
- **Mobile-First**: Apps designed for mobile, not desktop ports
- **Real-Time**: Collaboration, live updates, instant feedback
- **Privacy/Security**: Data sovereignty, encryption, compliance
- **Integration**: API-first design, webhooks, third-party ecosystem
- **Analytics**: Data-driven features, visibility, reporting
- **Accessibility**: WCAG compliance, inclusive design
- **Sustainability**: Performance optimization, resource efficiency

## Ideation Patterns

### Variations on Existing Features

- **Expansion**: Add new use cases to existing feature (scheduling → recurring scheduling)
- **Personalization**: Make feature adapt to user/context (generic settings → smart defaults)
- **Integration**: Connect feature with other tools (task list → calendar sync)
- **Acceleration**: Speed up existing workflow (manual entry → import/bulk)

### New Feature Categories

- **Efficiency**: Speed up existing tasks
- **Discovery**: Help users find/learn features
- **Control**: Fine-grained settings and customization
- **Collaboration**: Enable teamwork and sharing
- **Reporting**: Visibility into data and metrics
- **Automation**: Reduce manual work

## Roadmap Building Template

```
# H1 2024 Roadmap

## Quick Wins (Next Sprint)
- Feature A (1 week, high impact)
- Feature B (3 days, solves top complaint)

## Q1-Q2 Strategic Bets
- Feature C (3 weeks, high-value improvement)
- Feature D (2 months, new capability category)

## Future (Q3+)
- Feature E (2 months, transformational)
- Feature F (architectural work needed first)

## Blockers & Dependencies
- Feature F blocked by: Architecture refactor (on roadmap Q2)
- Feature D requires: New API integration (in progress)
```
