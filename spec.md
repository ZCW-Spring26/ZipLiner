# ZipLiner
## Product Specification
**The Private Professional Network for ZipCode Wilmington Students & Alumni**

> Version 0.1 — DRAFT FOR DISCUSSION
> ZipCode Wilmington | CodeHavn, LLC

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Goals and Non-Goals](#2-goals-and-non-goals)
3. [Membership and Identity](#3-membership-and-identity)
4. [Cohorts](#4-cohorts)
5. [Connections and the Network Graph](#5-connections-and-the-network-graph)
6. [The Feed](#6-the-feed)
7. [Project Showcase](#7-project-showcase)
8. [LinkedIn Integration](#8-linkedin-integration)
9. [Direct Messaging](#9-direct-messaging)
10. [Notifications](#10-notifications)
11. [Administration and Moderation](#11-administration-and-moderation)
12. [Technical Architecture](#12-technical-architecture-recommended)
13. [Privacy and Security](#13-privacy-and-security)
14. [Future Expansion Ideas](#14-future-expansion-ideas)
15. [Open Questions for Discussion](#15-open-questions-for-discussion)
16. [Glossary](#16-glossary)

---

## 1. Executive Summary

ZipLiner is a private, invite-only social and professional network exclusively for ZipCode Wilmington students and alumni. Its purpose is threefold: to sustain the community bond that forms during each cohort, to accelerate professional networking between graduates at different stages of their careers, and to give members a shared space for sharing work, celebrating wins, and surfacing resources relevant to their growth as developers.

The platform deliberately keeps scope narrow. It is not a replacement for LinkedIn, and it is not competing with public social networks. It is a curated, high-trust space where every member has already cleared a meaningful bar: they attended and completed ZipCode Wilmington. That shared context replaces much of the friction that large networks must overcome.

| Attribute | Value |
|---|---|
| Project Name | ZipLiner |
| Sponsor | ZipCode Wilmington |
| Legal Entity | CodeHavn, LLC |
| Version | 0.1 — Draft for Discussion |
| Status | Pre-development — Specification Phase |
| Auth Methods | GitHub OAuth2 (required) + LinkedIn OAuth2 (optional linkage) |
| Primary Audience | Active students, graduates, instructors, and staff of ZipCode Wilmington |

---

## 2. Goals and Non-Goals

### 2.1 Goals

- Provide a trusted, closed community where ZipCode alumni and students can connect authentically.
- Make it easy to share work-in-progress, finished projects, and GitHub activity.
- Enable members to surface articles, job postings, and news relevant to the developer community.
- Model the cohort structure of ZipCode, making it easy to find and reconnect with cohort-mates.
- Offer degree-of-connection awareness (1st / 2nd degree) to support targeted introductions.
- Bridge to LinkedIn so members can convert platform connections into full professional relationships.
- Use GitHub as the primary identity layer, reducing friction for the technical audience.

### 2.2 Non-Goals

- ZipLiner is not a job board (though job postings may be shared as feed content).
- ZipLiner is not a learning management system or replacement for any ZipCode curriculum tooling.
- ZipLiner does not attempt to replicate the full feature surface of LinkedIn or Bluesky.
- ZipLiner is not open to the general public; there is no self-serve signup without institutional affiliation.

---

## 3. Membership and Identity

### 3.1 Eligibility

Membership in ZipLiner is restricted to individuals who have an active relationship with ZipCode Wilmington in one of the following roles:

| Role | Description | Invitation Method |
|---|---|---|
| Student (Active) | Currently enrolled in a ZipCode cohort | Auto-provisioned by staff at cohort start |
| Alumni | Graduate of a completed ZipCode cohort | Auto-provisioned on graduation OR self-request verified by staff |
| Instructor / Staff | ZipCode Wilmington employee or contractor | Provisioned by admin |
| Mentor / Guest | External mentor recognized by ZipCode staff | Invite-only, issued by admin |

### 3.2 Authentication — GitHub OAuth2 (Primary)

All members authenticate via GitHub OAuth2. This is the required identity anchor for the platform. There is no username/password option. GitHub was chosen because:

- The entire ZipCode student population already has a GitHub account as a prerequisite of the program.
- GitHub identity provides an immediate, verifiable signal of technical participation.
- It eliminates password management complexity and reduces account-recovery surface area.
- Public GitHub profile data (avatar, bio, pinned repos, contribution graph) can be surfaced on ZipLiner profiles with member consent.

> **Implementation note:** Use GitHub's standard OAuth2 flow (authorization_code grant). Store the GitHub user ID and username as the canonical identity key, not the email, since email can change.

### 3.3 Authentication — LinkedIn OAuth2 (Optional Linkage)

Members may optionally link a LinkedIn account to their ZipLiner profile. This is purely additive — it does not replace GitHub auth. Linking LinkedIn enables:

- Display of a verified LinkedIn profile badge and direct link on the member's ZipLiner profile card.
- One-click "Connect on LinkedIn" affordance visible to other ZipLiner members.
- Optional pull of LinkedIn headline and profile photo as an alternative to GitHub avatar.
- Future capability: cross-platform mutual connection suggestions.

> **LinkedIn OAuth2** uses the "Sign In with LinkedIn using OpenID Connect" flow. Request only the `openid`, `profile`, and `email` scopes. Do not request `w_member_social` or other write scopes — ZipLiner will not post to LinkedIn on a member's behalf.

### 3.4 Profile

Each member has a profile that combines data from connected accounts with self-entered information:

| Field | Source | Required? |
|---|---|---|
| Display name | GitHub / self-entry | Yes |
| Avatar / photo | GitHub or LinkedIn (member chooses) | Yes |
| Short bio | Self-entry (280 chars) | No |
| Current role / title | Self-entry | No |
| Employer / company | Self-entry | No |
| Location (city) | Self-entry | No |
| Cohort | Assigned by admin at provisioning | Yes |
| Graduation year | Derived from cohort | Auto |
| GitHub username + link | From GitHub OAuth | Auto |
| LinkedIn URL | From LinkedIn OAuth linkage | Optional |
| Pinned projects | Self-selected from GitHub repos or manual entry | No |
| Skills tags | Self-entry (e.g., Java, Python, React, SQL) | No |
| Open to opportunities | Boolean toggle | No |

---

## 4. Cohorts

### 4.1 Cohort Model

The cohort is the fundamental organizational unit of ZipLiner, mirroring the structure of ZipCode Wilmington itself. Every member is assigned to exactly one cohort at provisioning. Cohorts have:

| Attribute | Description |
|---|---|
| Cohort Name | Human-readable name (e.g., "Spring 2024", "Cohort 42", or a ZipCode-assigned theme name) |
| Start Date | When the cohort began instruction |
| Graduation Date | When the cohort completed the program |
| Roster | List of members who attended (visible to all authenticated members) |
| Cohort Channel | A private discussion channel visible only to cohort members and staff |
| Cohort Page | A public-within-ZipLiner page summarizing the cohort, its graduates, and notable projects |

### 4.2 Cohort-Aware Features

- Members can filter the "People" directory by cohort.
- A cohort badge appears on every profile card and post attribution line.
- The Cohort Channel is a semi-private space: members of that cohort plus all instructors/staff can post; others can be granted read access by a cohort member.
- Alumni from older cohorts are encouraged to engage with newer cohort channels as mentors.
- "Cohort Reunions" — periodic in-platform events auto-created on cohort anniversaries — are a future feature (see Section 14).

---

## 5. Connections and the Network Graph

### 5.1 Connection Model

ZipLiner uses a bidirectional connection model (like LinkedIn, unlike Twitter/Bluesky's follow model). Two members are "connected" when both have accepted a connection request. The connection graph enables degree-of-connection calculations.

### 5.2 Degrees of Connection

| Degree | Definition | Display |
|---|---|---|
| 1st Degree | You are directly connected to this person | Blue "1st" badge on profile card |
| 2nd Degree | You share at least one mutual 1st-degree connection | Teal "2nd" badge; shows count of shared connections |
| 3rd+ Degree | Connected through two or more intermediaries | Gray "3rd+" badge; no shared connection count shown |
| Cohort-mate | Same cohort, regardless of connection status | Cohort icon shown; always visible |
| No connection | No path found within 3 hops | No badge shown |

> **Implementation note:** Degree calculation runs on demand (or cached at login) using a BFS traversal of the member's local connection graph. For the expected network size of ZipCode alumni, this is computationally trivial and does not require a dedicated graph database — a standard relational model with a `connections` table suffices.

### 5.3 Introduction Requests

A 2nd-degree member may request an introduction through a shared connection. The shared connection receives an in-app notification asking if they are willing to facilitate. This is soft and social — no automated forwarding. The shared connection can share contact details, make an in-app introduction post, or simply decline.

---

## 6. The Feed

### 6.1 Feed Philosophy

ZipLiner's feed is chronological by default. There is no engagement-optimizing algorithm. Members see posts from people they are connected to, from cohort channels they belong to, and from any topic channels they have subscribed to. This is an intentional design choice: the community is small and high-trust, and algorithmic amplification would distort it.

### 6.2 Post Types

| Post Type | Description | Max Length |
|---|---|---|
| Status Update | Short text post, Bluesky-style microblog. Supports @mentions and #hashtags. | 300 chars |
| Article Share | Share an external URL with a title, source name, and commentary. Renders a link preview card. | URL + 500 char note |
| Project Showcase | Structured post: project name, GitHub repo link, demo link, tech stack tags, description. | 800 chars |
| Long-form Post | Extended text post for essays, tutorials, retrospectives, or reflections. | 10,000 chars |
| Cohort Shoutout | Special post type tagged to a cohort, visible on the cohort page. | 300 chars |
| Job Signal | Brief post indicating availability: role type, location preference, open to contact. | Structured fields only |

### 6.3 Reactions and Replies

- Reactions: a small fixed set (e.g., thumbs-up, fire, lightbulb, celebrate) — no dislike or downvote.
- Replies are threaded one level deep (reply to post; no infinite nesting).
- Replies from the original poster are highlighted to make conversations easier to follow.
- @mention notifications are delivered in-app and optionally via email digest.

### 6.4 Content Channels

| Channel Type | Created By | Visibility | Examples |
|---|---|---|---|
| Cohort Channel | Auto-created per cohort | Cohort members + staff | #cohort-spring-2024 |
| Topic Channel | Any member; requires admin approval | All members | #java-tips, #jobs, #side-projects |
| Staff Channel | Admin-created | All members (read); staff only (write) | #announcements, #events |
| DM / Private Thread | Any connected member | Participants only | Direct messages |

---

## 7. Project Showcase

### 7.1 Overview

Project Showcase is a first-class feature designed to make it easy for members to display what they are building. It is accessible as a structured section on every profile, and Project Showcase posts surface in the feed and in a dedicated "Projects" browse view.

### 7.2 Project Entry Fields

| Field | Type | Notes |
|---|---|---|
| Project Name | Text (80 chars) | Required |
| Tagline | Text (120 chars) | Short description |
| Description | Markdown (800 chars) | Supports basic formatting |
| Status | Enum | In Progress / Completed / Archived / Looking for Collaborators |
| GitHub Repository URL | URL | Optional; renders commit activity widget if public |
| Live Demo URL | URL | Optional |
| Tech Stack Tags | Multi-select | Curated list + freeform |
| Role on Project | Text | e.g., "Solo", "Backend Lead", "Contributor" |
| Collaborators | ZipLiner member search | Links to collaborators' profiles |
| Media | Image upload (up to 3) | Screenshots, diagrams, demo GIFs |
| Cohort Project? | Boolean | Tags project as a ZipCode cohort deliverable |

> If a GitHub repo URL is provided and the repo is public, ZipLiner may display a live commit count, primary language badge, and star count via the GitHub REST API. This requires no additional auth.

---

## 8. LinkedIn Integration

### 8.1 Profile Linkage

When a member links their LinkedIn account via OAuth2, their ZipLiner profile displays a prominent "Connect on LinkedIn" button. Clicking this button opens the member's LinkedIn public profile in a new tab. This is the primary LinkedIn integration surface and requires no special LinkedIn API permissions beyond basic profile read.

### 8.2 Connection Bridge

When viewing another member's profile, if they have linked LinkedIn, the viewer sees:

- A "View LinkedIn Profile" button that deep-links to their public LinkedIn URL.
- If the viewer has also linked LinkedIn, a "Connect on LinkedIn" button is shown with a short message template pre-filled (e.g., "Hi [name], I know you through ZipCode Wilmington — let's connect here too!").

### 8.3 LinkedIn URL Without OAuth

Members who do not wish to complete LinkedIn OAuth linkage may still manually enter their LinkedIn profile URL in their profile settings. This renders the same "View LinkedIn Profile" button without the mutual-connection awareness feature.

### 8.4 Scope and Permissions

> ZipLiner requests only read scopes from LinkedIn (`openid`, `profile`, `email`). ZipLiner will never post to LinkedIn, never read a member's LinkedIn connections, and never store LinkedIn access tokens after the initial profile data pull unless the member explicitly re-links. This constraint is both a privacy commitment and a requirement of LinkedIn's API policies for this use tier.

---

## 9. Direct Messaging

Members who are 1st-degree connections may send direct messages to each other. DMs are private, visible only to participants, and are not indexed in any feed or search. Key constraints:

- Non-connected members may send a single connection request message (limited to one message until accepted).
- Members may mute or block any other member. Blocks are private and mutual: the blocked member cannot see the blocker's profile or content.
- Staff/admin accounts may send broadcast messages to cohort channels but not DMs to members without consent.
- No read receipts by default. A member may opt in to showing read receipts in settings.

---

## 10. Notifications

### 10.1 In-App Notifications

| Event | Notification Type |
|---|---|
| Someone connects with you | In-app badge + feed item |
| Someone @mentions you | In-app badge + email (if opted in) |
| Someone replies to your post | In-app badge |
| Someone reacts to your post | In-app badge (batched — not per-reaction) |
| New post in a cohort channel you belong to | In-app badge |
| Introduction request received | In-app badge + email |
| A connection posts a new Project Showcase | Feed item (not push notification) |
| Staff announcement | In-app banner |

### 10.2 Email Notifications

Email notifications are opt-in and configurable per category. A daily digest is available as an alternative to per-event emails. ZipLiner will not send promotional email without explicit opt-in separate from notification preferences.

---

## 11. Administration and Moderation

### 11.1 Admin Roles

| Role | Capabilities |
|---|---|
| Super Admin | Full access: provision/deprovision any member, manage cohorts, view audit logs, override all settings |
| Staff Admin | Provision students/alumni, manage cohort assignments, post to announcement channels |
| Cohort Moderator | A designated alumni per cohort who can moderate their cohort channel |

### 11.2 Member Provisioning

- Admins provision new members by entering their GitHub username. The system sends an invitation email.
- On first GitHub OAuth login, the member completes onboarding: cohort confirmation, profile setup.
- Deprovisioning suspends access immediately; content is soft-deleted (hidden) but retained for 90 days for audit purposes.

### 11.3 Content Moderation

- Any member may report a post or comment. Reports are routed to admin for review.
- Admins may remove content, issue warnings, or suspend accounts.
- There is no automated content moderation (AI filter) in v1. The community is small enough for manual review.

---

## 12. Technical Architecture (Recommended)

### 12.1 Stack Recommendations

| Layer | Recommended Technology | Notes |
|---|---|---|
| Frontend | React + TypeScript | Or Next.js for SSR; mobile-responsive from day one |
| Backend API | Java (Spring Boot) or Python (FastAPI) | Either aligns with ZipCode curriculum — consider instructional value |
| Auth | OAuth2 via GitHub + LinkedIn | Use a library: Spring Security OAuth2 or Authlib (Python) |
| Database | PostgreSQL | Relational model is sufficient for this graph scale |
| Object Storage | AWS S3 or Cloudflare R2 | Profile images, project media |
| Real-time | WebSockets (Spring / FastAPI) | DMs and live notification badges |
| Email | AWS SES or Resend | Transactional and digest emails |
| Hosting | AWS, Render, or Fly.io | Start simple; containerize from day one |
| CI/CD | GitHub Actions | Natural fit given GitHub-centric identity |

> **Curriculum note:** Building ZipLiner in Java (Spring Boot) + React would serve a dual purpose: a production application AND a living reference implementation for students. The codebase could be studied, contributed to, and used as a capstone reference.

### 12.2 Data Model (Conceptual)

| Entity | Key Fields | Key Relationships |
|---|---|---|
| Member | id, github_id, linkedin_id?, display_name, cohort_id, role, status | belongs to Cohort; has many Connections |
| Cohort | id, name, start_date, graduation_date | has many Members |
| Connection | member_id_a, member_id_b, status (pending/accepted), created_at | links two Members |
| Post | id, author_id, type, content, channel_id?, created_at | belongs to Member; has many Reactions, Replies |
| Project | id, owner_id, name, repo_url, demo_url, status, tags[] | belongs to Member; has many Collaborators |
| Channel | id, type, name, cohort_id? | has many Posts; has many Memberships |
| Notification | id, recipient_id, type, payload_json, read_at? | belongs to Member |
| DirectMessage | id, sender_id, recipient_id, content, sent_at | links two Members |

---

## 13. Privacy and Security

- ZipLiner is a closed network. No content is publicly accessible without authentication.
- Member profiles are visible only to other authenticated ZipLiner members.
- GitHub and LinkedIn OAuth tokens are stored encrypted at rest. Access tokens are rotated on each auth session.
- Members may download all of their own data (GDPR-style data export) regardless of jurisdiction.
- Members may delete their account, which anonymizes their content and removes their profile from the directory.
- No third-party analytics or advertising SDKs are embedded in ZipLiner.
- All traffic is served over HTTPS/TLS. API endpoints require authentication; no public endpoints expose member data.
- Audit logs are retained for 12 months for admin actions (provisioning, deprovisioning, content removal).

---

## 14. Future Expansion Ideas

The following features are explicitly out of scope for v1 but are worth discussing and planning for. Listed roughly in priority order based on community value.

### 14.1 Events and Cohort Reunions

- In-platform event posts: date, location, RSVP count, Zoom/meet link for virtual events.
- Auto-created "Cohort Anniversary" events (1-year, 5-year milestones) to re-engage alumni.
- ZipCode-hosted networking events, speaker series, and career fairs surfaced to all members.

### 14.2 Job Board Integration

- A structured jobs tab where members can post openings at their employers.
- Job posts include a "Referred by ZipLiner member" flag, encouraging warm referrals.
- Integration with LinkedIn Jobs API (if available) to surface relevant listings.

### 14.3 Mentorship Matching

- A lightweight opt-in mentorship program: senior alumni offer to mentor recent graduates.
- Matching considers cohort, tech stack tags, industry, and stated goals.
- Structured "office hours" slots that mentors can publish on their profiles.

### 14.4 GitHub Activity Feed Integration

- Optional: surface a member's public GitHub contribution activity on their profile (commit graph, recent pushes).
- "Today I Shipped" automated post type: member authorizes a GitHub webhook; a post is auto-drafted when they push to a public repo.

### 14.5 ZipCode Learning Integration

- Read-only integration with ZipCode's internal curriculum tools to display cohort curriculum progress on student profiles (with consent).
- "Badge" system for curriculum milestones (completed Java fundamentals, shipped first REST API, etc.) — earned through ZipCode coursework, displayed on ZipLiner profiles.

### 14.6 Mobile Application

- A React Native (or Flutter) mobile app for iOS and Android.
- Push notifications via FCM/APNs for DMs and @mentions.
- Mobile-first camera integration for quick project update photo posts.

### 14.7 Alumni Spotlight

- A curated, human-edited "Spotlight" section showcasing alumni career highlights, promotions, and shipped products.
- Submitted by the member; reviewed by staff before publication.

### 14.8 Skill Endorsements

- 1st-degree connections may endorse each other's skills (similar to LinkedIn endorsements).
- Endorsements are visible on profiles but are not gamified or ranked.

### 14.9 ZipLiner API / Developer Mode

- A public-within-ZipLiner read API for member data (opt-in) — so members can build personal dashboards, integrations, or tools using their own ZipLiner data.
- This is a natural capstone project idea for advanced cohorts.

### 14.10 Federation / ActivityPub

- Long-term: implement the ActivityPub protocol so ZipLiner profiles can be followed from Mastodon or Bluesky (for members who opt in to public federation).
- This preserves the closed nature of the network internally while allowing members to broadcast selectively to the wider developer community.

---

## 15. Open Questions for Discussion

1. Who owns and operates ZipLiner — ZipCode Wilmington as an institution, or CodeHavn LLC as a product entity? This affects branding, liability, and potential commercialization.
2. Is there a desire to allow ZipCode alumni from other cities if ZipCode expands? The cohort model supports this, but it changes the community character.
3. Should instructors and staff have fully visible profiles and connections, or a distinct "Staff" mode that is more limited in social features?
4. What is the content moderation policy for job postings shared in the feed? Should there be a separate, structured jobs section to avoid feed pollution?
5. What is the plan for members who were enrolled but did not complete a cohort? Are they eligible for membership?
6. Should ZipLiner allow cohort channels to be archived (read-only) after a cohort graduates, or kept fully active indefinitely?
7. What is the acceptable hosting cost threshold, and how does that affect infrastructure choices?
8. Is there interest in making ZipLiner a student-built capstone project, with its spec evolving based on what cohorts actually build?

---

## 16. Glossary

| Term | Definition |
|---|---|
| ZipLiner | The name of the private social/professional network for ZipCode Wilmington members |
| Cohort | A specific group of students who went through ZipCode Wilmington together in the same term |
| 1st Degree | A direct connection — someone who has accepted your connection request or vice versa |
| 2nd Degree | A member connected to one of your 1st-degree connections, but not directly to you |
| Project Showcase | A structured post type for displaying a project with GitHub links, tech stack, and media |
| LinkedIn Bridge | The feature that links a LinkedIn profile to a ZipLiner profile for cross-network connections |
| GitHub OAuth2 | The primary authentication mechanism; members log in using their GitHub credentials |
| Topic Channel | A member-created discussion channel organized around a specific topic (e.g., #jobs, #java-tips) |
| Job Signal | A structured post type indicating a member is open to employment opportunities |
| DM | Direct Message — a private one-on-one conversation between two members |

---

*— End of Document —*
