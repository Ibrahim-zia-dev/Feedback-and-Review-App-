# UI/UX Design Brief for Feedback & Review App

## 1. Product intent

This product is a mobile-first feedback and review application designed for organizations that need to collect structured feedback from contributors and act on it efficiently through a centralized admin workflow. The app must enable fast collection of ratings and comments, clear visibility of feedback status, and dependable triage for administrators.

The experience should feel:
- Trustworthy and professional
- Fast to complete on mobile
- Structured and low-friction
- Clear about privacy, status, and next steps

### UX outcomes
- Contributors can submit feedback in under 2 minutes without confusion.
- Administrators can review, filter, assign, and resolve feedback with minimal friction.
- All interactions feel safe, transparent, and understandable.

---

## 2. Design strategy and brand direction

### Overall visual language

Use a modern enterprise productivity aesthetic with slightly softer app-like character than a strict dashboard tool. The interface should look credible, organized, and calm rather than consumer-social or overly playful.

### Desired tone
- Professional
- Calm
- Efficient
- Helpful
- Minimal but expressive

### Design personality keywords
- Trust-centered
- Operational
- Modern
- Thoughtful
- Clean and functional

### Visual goals
- Make every task feel lightweight and guided
- Reduce cognitive load in review and form flows
- Surface status and action clearly at all times
- Emphasize clarity over decoration

---

## 3. Core UX principles

1. Clarity before cleverness
   - Use familiar patterns and minimal ambiguity.
   - Label actions plainly and explain status changes in user terms.

2. Respect user effort
   - Keep major tasks short, skim-friendly, and mobile-first.
   - Use progressive disclosure and avoid unnecessary steps.

3. Design for trust
   - Privacy and visibility rules must be visible before the user submits feedback.
   - Avoid hidden assumptions or vague language.

4. Make next actions obvious
   - Every screen should clearly communicate what can be done now and what happens next.

5. Use status as a primary interface language
   - Status chips, summary tags, and timeline states should help users understand progress immediately.

6. Reduce friction in data entry
   - Rating questions should be highly scannable.
   - Comments and suggestions should be optional unless specifically required.

7. Support both contributor and admin mental models
   - Contributor flows are short, reassuring, and outcome-oriented.
   - Admin flows are analytical, filter-driven, and action-oriented.

---

## 4. Target user needs

### Contributor users

Primary needs:
- Know what feedback is being requested
- Understand who can see the response
- Submit quickly without confusion
- Feel confident the response was received
- See the status of past feedback

### Administrator users

Primary needs:
- Review volume and trends at a glance
- Filter feedback by context, date, status, and rating
- Prioritize attention-worthy items
- Assign tasks and track resolution
- Manage contexts and organization-level workflows efficiently

### User experience expectations
- Minimal friction in onboarding and repeated usage
- Strong visual priority for important actions
- Clean information hierarchy for dashboards and response detail
- Transparent feedback about confidentiality and action status

---

## 5. Design system: color palette

The app should rely on a disciplined, professional palette. Use the blue family for the product identity, with teal as a supportive success accent, gold as a rating highlight, and red only for urgency or errors.

### Core palette

| Role | Name | Hex | Use |
|---|---|---:|---|
| Primary | Deep Blue | #1F4D9A | Primary actions, active nav, selected states |
| Primary Dark | Midnight Navy | #102A43 | Headlines, emphasized text, strong surfaces |
| Accent | Teal | #2BB3A9 | Success, confirm states, positive metrics |
| Highlight | Warm Gold | #E8B84B | Ratings, highlight states, attention |
| Critical | Coral Red | #E25A5A | Error states, urgent flags, destructive actions |
| Text Strong | Charcoal | #1F2937 | Primary text |
| Text Secondary | Slate | #475569 | Secondary labels and helpers |
| Muted | Gray | #94A3B8 | Placeholder and secondary metadata |
| Border | Mist | #E2E8F0 | Dividers, outlines, subtle cards |
| Surface | Cloud | #F8FAFC | Background surfaces |
| Card | White | #FFFFFF | Cards and panels |
| Success Surface | Mint | #EAFBF7 | Confirmations, good states |
| Warning Surface | Sand | #FFF7E8 | Pending or attention states |

### Palette rules
- Blue is the dominant brand color and should appear most often.
- Use teal for positive confirmation, completion, and success actions.
- Use gold sparingly for ratings or highlights; do not make it the main app color.
- Use red only for errors, critical warnings, and destructive steps.
- Maintain strong contrast for readability and accessibility.

### Emotional intent
- Blue = trust, control, professionalism
- Teal = clarity, completion, safety
- Gold = value, attention, positive feedback
- Red = urgency, risk, correction

---

## 6. Typography system

Use a modern sans-serif type system with clear hierarchy and strong readability on small mobile screens.

### Recommended type families
- Inter
- Manrope
- SF Pro Display
- Roboto Flex

### Type scale

| Style | Size / Line Height | Weight | Use |
|---|---:|---:|---|
| Display | 32 / 40 | 700 | Hero summaries, major title screens |
| H1 | 28 / 36 | 700 | Screen titles |
| H2 | 22 / 30 | 600 | Section titles |
| H3 | 18 / 26 | 600 | Card titles and list headings |
| Subtitle | 16 / 24 | 500 | Supporting headings and metadata |
| Body Large | 16 / 24 | 400 | Key form copy and detailed text |
| Body | 14 / 22 | 400 | Standard content |
| Caption | 12 / 18 | 500 | Tags, labels, timestamps |
| Meta | 11 / 16 | 600 | Small uppercase/functional labels |

### Typography rules
- Use strong hierarchy rather than high decoration.
- Favor direct, plain-language labels over abstract labeling.
- Limit font weight variations to maintain consistency.
- Keep line lengths readable and avoid dense paragraphs.
- Use labels for status, category, and metadata so the user can scan quickly.

---

## 7. Layout system and spacing

### Layout direction

The app should be predominantly single-column and mobile-first. Scroll-based vertical stacking is preferred for user flows. Multi-column layouts are acceptable for admin tablets or desktop expansion, but only after content is organized into distinct information blocks.

### Core layout principles
- Use a stacked vertical rhythm for primary flows
- Keep only one clear primary action per screen when possible
- Group related information into cards or sections
- Build list layouts for tasks, inbox items, and submissions
- Reserve large horizontal space for dashboards and analytics views on larger screens

### Spacing scale

Use an 8-point spacing system:
- 4, 8, 12, 16, 20, 24, 32, 40, 48, 64

### Layout rules
- Keep content padding at 16-20 px on phones
- Maintain consistent margins between sections
- Use large spacing around key action surfaces
- Use subtle elevation and card borders instead of excessive visual noise

### Card metrics
- Border radius: 16-20px
- Border: 1px solid neutral border
- Shadow: subtle elevation only, no heavy drop shadows
- Card padding: 16-20px

---

## 8. Component design language

### Buttons

#### Primary action button
- Fill: Deep Blue
- Text: White
- Height: 48-56 px
- Radius: 12-16 px
- Strong contrast and clear emphasis
- Use for submit, continue, save, confirm

#### Secondary action button
- Fill: white or neutral surface
- Border: 1px solid border color
- Text: dark neutral
- Use for cancel, back, filter, or secondary tasks

#### Text action button
- No background
- Blue or slate text
- Minimal visual weight
- Use for dismissive, inline, or low-priority choices

#### Destructive button
- Fill: coral or outlined red
- Use only for irreversible or critical actions

### Input fields
- Rounded rectangle with 12-16px radius
- Border color: neutral 200
- Focus state: deep blue outline and stronger border
- Clear label above field
- Helper text beneath field
- Error text in red, aligned under the field
- Default height 48-56 px

### Rating components
- Use a 1-5 scale with clear active/inactive states
- Large touch targets
- Provide visible selection feedback using fill, glow, or highlight
- Show numeric value or clearly selected state for accessibility

### Status chips
Use compact pills for:
- New
- In review
- Actioned
- Archived
- Active
- Paused
- Closed

Chip styling: 
- Rounded pill
- Medium weight label
- Accessible contrast
- Background color indicates status tone
- Keep chip height compact and consistent

### Cards and lists
- Use white surfaces with subtle borders
- Each list item should contain title, metadata, status, and action affordance
- Include timestamp, context tag, and status summary where relevant
- Primary text should remain unmistakable and not compete with decorative elements

### Navigation
- Bottom tab bar for primary destinations on mobile
- Top app bar for contextual actions and titles
- Keep navigation consistent and limited to essential destinations
- Avoid hidden actions if they are core to the task flow

---

## 9. Screen architecture and key user journeys

### Contributor journey

1. Sign in or access account
2. View available feedback requests
3. Select an active context
4. Review privacy and visibility notice
5. Rate the experience
6. Add optional review and suggestion
7. Submit
8. See confirmation and status
9. View personal history

### Administrator journey

1. Open dashboard overview
2. Review summary metrics
3. Filter inbox by context, status, rating, date
4. Open feedback detail
5. Assign, review, or resolve response
6. Add internal notes
7. Update status
8. Return to dashboard or queued items

### Key screens

#### 1. Authentication screen
- Simple sign-in flow
- Clear call to action
- Secondary controls for sign-up and password reset
- Minimal clutter; no extra illustration overload

#### 2. Home / active request list
- Personalized greeting or context summary
- Card list of requested feedback opportunities
- Inline metadata: context name, due date, relevance
- Clear action button: Review or Respond

#### 3. Feedback submission screen
- Context title and purpose
- Short explanation of what the app is collecting
- Privacy disclosure in plain language
- 1-5 rating input
- Comment field for optional review
- Suggestion field for optional improvement note
- Final submit button
- Validation warnings only when needed

#### 4. Confirmation screen
- Success state with clear confirmation text
- Summary of rating and context
- Next-step action to return home or view submissions

#### 5. Response detail for admin
- Context label
- Contributor visibility note
- Response rating
- Text comments and suggestions
- Status timeline
- Internal note section
- Assignment actions and triage options

#### 6. Admin dashboard
- Summary metric row with total, average, new, actioned
- Rating distribution chart or simple progress bars
- Recent feedback requiring attention
- Top contexts by score or activity
- Date range switcher for filtering

---

## 10. Dashboard structure and analytics design

The dashboard should provide a fast high-level view without becoming visually dense. The design must support scanning, comparison, and action-taking in seconds.

### Dashboard layout

Top row:
- Date range selector
- Filter button
- Search or quick filter summary

Metric summary row:
- Total responses
- Average rating
- New items
- Actioned items

Insights area:
- Rating distribution
- Weekly or monthly response trend
- Context comparison panel

Attention panel:
- Low-rated contexts
- Recently updated items
- Unresolved feedback needing follow-up

### Dashboard design rules
- Place the most important metric or issue first
- Keep metrics card layouts consistent
- Use a limited number of colors to maintain clarity
- Provide labels and supporting text for every major metric
- Charts should feel clean and legible, never decorative

### Metric card pattern
- Label
- Primary value
- Small secondary delta or trend indicator
- Optional support text

---

## 11. Mobile responsiveness

The app should be designed mobile-first, with reliable behavior across common device sizes.

### Mobile behavior
- Single-column layout by default
- Sticky bottom nav for core destinations
- Primary content should be reachable in one thumb-friendly path
- Avoid multi-step action groups in repeated flows
- Ensure text remains readable at smallest screen widths

### Tablet behavior
- Use split-pane layouts for admin content where appropriate
- Dashboard cards can expand to a 2x2 or 3-column arrangement
- Detail view can sit beside list view for triage workflows

### Desktop / web extension behavior
- Preserve mobile-first information hierarchy
- Keep screens simpler than dense enterprise dashboards
- Avoid forcing desktop patterns into a mobile app structure

### Responsive rules
- Do not hide essential actions behind overflow menus on phones
- Keep form fields and controls comfortably tappable
- Maintain legible charts and summaries on compact screens

---

## 12. User experience states

### Empty states
Examples:
- “No active feedback requests right now.”
- “No items match your current filters.”
- “There are no contexts available yet.”

Empty states should include:
- Clear explanation
- Optional guidance or next action
- Sufficient spacing to feel intentional, not broken

### Loading states
- Use skeletons or subtle placeholders when data is loading
- Keep layout stable to prevent unexpected jumps
- Show progress states for action completion

### Error states
- Explain what failed in plain language
- Offer a clear retry or correction action
- Avoid exposing technical errors to end users

### Success states
- Use a visible confirmation with summary and next step
- Keep the action state short and confident
- Confirm completion with strong but not excessive language

### Validation states
- Trigger validation when the user interacts with the field or attempts submit
- Show inline error text under the field
- Keep the validation tone helpful and reassuring

---

## 13. Accessibility and inclusive design

The app should be inclusive by default.

- Maintain high contrast for all text and controls
- Use a minimum 44x44 px tap target for interactive controls
- Ensure keyboard and screen-reader support for all critical actions
- Pair color with text or icon to indicate state meaning
- Use concise, descriptive labels and headings
- Avoid ambiguous or low-contrast chips and navigation states

---

## 14. Visual references and inspiration

The design direction should combine three influences:

### 1. Calm enterprise productivity apps
- Light backgrounds
- Clean cards
- Minimal but clear visual density
- Strong hierarchy and stable spacing

### 2. Modern feedback and survey tools
- Friendly progress states
- Clear forms with guided flow
- Comfortable confirmation screens
- Strong emphasis on privacy and trust

### 3. B2B admin dashboard systems
- Summary metrics
- Structured list views
- Controlled color usage
- Functional, low-noise presentation

### Overall inspiration summary
The final product should not feel playful, social, or consumer-oriented. It should feel like a premium internal tool or operational feedback system: trustworthy, useful, and focused on real action.

---

## 15. AI app builder implementation rules

Use these rules when generating screens or iterating on the UI:

1. Keep surfaces mostly light and clean.
2. Use blue as the primary app color; teal is success; gold is secondary highlight; red is urgency only.
3. Prefer card-based layout systems over dense, highly decorative screens.
4. Keep mobile-first flows extremely simple and readable.
5. Use strong hierarchy with typography, spacing, color, and contrast.
6. Every critical action should have a visible confirmation or status change.
7. Avoid decorative illustration overload and visual clutter.
8. Admin interfaces must be filter-centric, list-oriented, and easy to scan.
9. Contributor flows must feel low-pressure, short, and privacy-aware.
10. Maintain consistent shapes, spacing, and component styling across all screens.

---

## 16. Final design direction summary

The app should feel like a polished, trustworthy, mobile-first feedback platform designed for real-world operational use.

- Contributor experience: quick, reassuring, privacy-aware, low-friction
- Admin experience: structured, efficient, filter-driven, actionable
- Visual tone: modern, professional, calm, credible
- Interaction style: clear status signals, compact cards, confident actions, minimal noise
- Primary objective: make feedback easy to give and easy to act on

---

## 17. UI token set for implementation

```text
Primary: #1F4D9A
PrimaryDark: #102A43
AccentTeal: #2BB3A9
AccentGold: #E8B84B
Critical: #E25A5A
TextPrimary: #1F2937
TextSecondary: #475569
Muted: #94A3B8
Border: #E2E8F0
Background: #F8FAFC
Card: #FFFFFF
SuccessBg: #EAFBF7
WarningBg: #FFF7E8
RadiusSm: 8px
RadiusMd: 12px
RadiusLg: 16px
RadiusXL: 20px
SpacingBase: 8px
ShadowSoft: 0 6px 18px rgba(16, 42, 67, 0.08)
```

This brief is intentionally specific enough to guide screen generation, component design, and visual consistency across the app.
