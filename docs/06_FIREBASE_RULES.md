# Firestore Security Rules

## ⚠️ Current state: no rules file exists in the repository

There is no `firestore.rules` anywhere in the repo. That means the project is either running
on Firebase's default rules (deny-all or fully-open test-mode rules, depending on when the
project was created) or the rules live only in the Firebase console and are undocumented and
unversioned. **Either way this is a critical gap** — the next agent to touch any collection
should not assume protection exists.

**Action item (should be near the top of `15_TODO.md`):** add a `firestore.rules` file to the
repo, put it under version control, and deploy it via `firebase deploy --only firestore:rules`
so rules stop being tribal knowledge.

## Intended access model (target — write this into `firestore.rules` once created)

| Collection group | Read | Write |
|---|---|---|
| `users/{uid}` | owner + org members with permission | owner only, cannot self-modify `role` |
| `organizations/{orgId}` | members of that org | org admins only |
| `products/{id}` | public | owning seller only |
| `carts/{id}` | owner | owner |
| `wishlist(s)/{id}` | owner | owner |
| `orders/{id}` | buyer + seller involved | **no direct client writes to payment/status
   fields** — those must go through a Cloud Function once one exists (see
   `08_PAYMENT_ARCHITECTURE.md`) |
| `rfqs/{id}`, `rfq_responses/{id}` | requester + invited suppliers | requester creates RFQ,
   invited suppliers create responses; neither can edit the other's data |
| `chat_sessions/{id}`, `chat_messages/{id}` | participants only | participants only, cannot
   edit/delete others' messages |
| `business_accounts/{id}` | public (storefront-facing fields) + owner (private fields —
   consider splitting into a public and private doc) | owner only |
| `transactions/{id}` | involved parties | **server-only** (Cloud Function), once payments exist |

## Principles

1. Never trust a client-supplied `role`, `verified`, `status: paid`, or `payout: released`
   field. If a rule can't verify it against something the client can't forge (a custom auth
   claim, or a server-only write), the field shouldn't be client-writable at all.
2. Prefer `request.auth.uid == resource.data.ownerId` patterns over collection-wide open reads,
   except for genuinely public data (product catalog).
3. Every new collection added anywhere in `lib/` must get a corresponding rule **in the same
   PR/task** — don't ship a feature that writes to an undocumented, unruled collection.
4. Rules should be testable — once the Emulator Suite is set up (`05_FIREBASE.md`), add rules
   unit tests under `test/` per collection.
