# Deployments — current manual process

Cloudflare Pages project: `life-rebuild-adr003-lab` (Direct Upload). The live app uses fictional test data only. The existing project is not connected to Git; **pushing to GitHub will NOT deploy it**.

When an app update is explicitly authorized and has been reviewed:

1. Zip **the contents of `site/`**, not the `site` directory itself (the ZIP should have `index.html` at its root).
2. In the **existing** Cloudflare Pages project, open Deployments -> Create deployment -> Production.
3. Upload the site ZIP and verify the deployment URL.
4. Open the Home Screen app on iPhone; validate safe areas, scroll width, navigation, login, and existing fictional data.
5. Confirm no database/schema changes are included accidentally.

Do not enable automatic deployment or switch Cloudflare projects without a separate decision. A push to this private repository is only source preservation for now.

Operational security debt: the current site loads an unpinned `@supabase/supabase-js@2` UMD CDN reference. Pin/version-lock before any production launch.
