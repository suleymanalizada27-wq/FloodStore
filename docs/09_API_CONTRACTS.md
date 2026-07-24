# API Contracts

## Current state
No server-side API exists yet (no Cloud Functions, no Supabase Edge Functions). This doc
defines the contract format to use once server functions exist — for payments
(`08_PAYMENT_ARCHITECTURE.md`), tender award (`database/09_DATABASE_FUNCTIONS.md`), and AI
agents (`modules/AI.md`).

## Format (use for every callable function / Edge Function once written)

```
### <functionName>

Request:
{
  field: type   // description
}

Response (success):
{
  field: type
}

Response (error):
{
  code: string,      // machine-readable
  message: string    // human-readable
}

Auth: <who can call this — role/claim required>
Validation: <key constraints>
Idempotency: <yes/no, and how (idempotency key, natural dedupe key)>
```

## First contracts to write (as these modules get built)

- `createPaymentIntent` — `docs/08_PAYMENT_ARCHITECTURE.md`
- `handlePaymentWebhook` — same
- `awardTender` — `docs/database/09_DATABASE_FUNCTIONS.md`
- `submitSealedBid` — same
- AI agent endpoints (`estimateProjectMaterials`, `scoreTenderBids`, etc.) —
  `docs/modules/AI.md`

Add each as its own section here the same task it's implemented, not after.
