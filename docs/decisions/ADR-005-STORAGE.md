# ADR-005: File/image storage

**Status:** Accepted (current) — Firebase Storage, no change proposed yet

**Decision:** Product images and other user-uploaded files continue to use Firebase Storage
(`product_image_service.dart`, `firebase_storage` dependency) even as the database migrates
toward Postgres/Supabase (ADR-002).

**Why not migrate storage too:** Supabase Storage is a viable alternative, but there's no
forcing function to move it — unlike the database (which needs relational modeling the
B2B/tender domain requires), file storage doesn't have a similar structural gap in Firebase
Storage. Migrating it adds risk (re-uploading/re-linking every existing product image) without
a corresponding benefit.

**Revisit if:** the team standardizes fully on Supabase for cost/ops-consolidation reasons, or
Supabase Storage offers a feature (e.g. tighter RLS-based access control matching the Postgres
model) that becomes a real requirement — at that point, write a new ADR rather than silently
moving storage.
