# Local Supabase audit workflow

This repo is set up so the frontend code and the Supabase-side security rules
can live together in git.

## One-time setup

Install Docker or another Docker-compatible runtime, then install the Supabase
CLI into the project:

```sh
npm install supabase --save-dev
```

Link the repo to the cloud project and pull the current schema/RLS baseline:

```sh
npx supabase login
npx supabase link --project-ref <your-project-ref>
npm run supabase:pull
```

That `db pull` step should create SQL under `supabase/migrations/`. Review and
commit that generated migration. From then on, avoid changing tables or RLS
directly in the cloud dashboard; make changes as migrations first.

Before relying on the local stack as a production mirror, check your cloud
Postgres version with:

```sql
show server_version;
```

Then keep `supabase/config.toml`'s `db.major_version` aligned with that major
version.

## Run locally

Start the local Supabase stack:

```sh
npm run supabase:start
npm run supabase:status
```

Copy `.env.local.example` to `.env.local`, then paste the local anon key printed
by `supabase status`.

```sh
npm run dev
```

Your Vite app should now talk to local Supabase at `http://127.0.0.1:54321`.
Local Studio runs at `http://127.0.0.1:54323`.

Your app currently signs in with Google. To test that exact flow locally,
uncomment `[auth.external.google]` in `supabase/config.toml`, set
`SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID` and
`SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_SECRET` in your shell, and add
`http://127.0.0.1:54321/auth/v1/callback` to the Google OAuth client's
authorized redirect URIs.

## Ongoing workflow

Create or update SQL migration files locally, then reset the local database to
prove the repo can rebuild the server-side state from scratch:

```sh
npm run supabase:reset
```

When the migration has been reviewed:

```sh
npm run supabase:push
```

For your current `Test` table, the key things to verify in the pulled SQL are:

- RLS is enabled on `public."Test"`.
- `select`, `insert`, `update`, and `delete` policies match your intended user
  boundaries.
- Any ownership column, such as `owner_id`, is checked with `auth.uid()` in the
  policy rather than trusted from React alone.
- Anonymous writes are not allowed unless you explicitly designed for them.
