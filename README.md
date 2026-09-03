# Portfolio site — deploy to GitHub Pages (free)

Everything is flat files, all in one place — no folders, no second repo needed.

1. In your GitHub account, create a new repository named `amnashahid999.github.io`
   (must match your username exactly — this gives you a live URL with no extra setup).
2. Upload **all of these files** to the root of that repository, all at once:
   - `index.html`
   - `qsli-framework.pdf`
   - `course-evaluation-response-rate-analysis.pdf`
   - `did-sehat-sahulat-evaluation.pdf`
   - `dlcp-dashboard.twbx`
   - `thesis-1-data-preprocessing.html`
   - `thesis-2-unsupervised-learning.html`
   - `thesis-3-supervised-learning.html`
   - `admissions-1-data-cleaning.html`
   - `admissions-2-enrollment-segmentation.html`

   (drag-and-drop works on github.com under "Add file → Upload files" —
   select all 10 files at once, or `git add / commit / push` if you're using
   the command line)
3. Go to the repo's **Settings → Pages** and confirm the source is set to
   your default branch (check the branch name shown just above the file
   list on the repo's main page — it'll say `main` or `master`), root
   folder. Click Save.
4. Your site will be live at `https://amnashahid999.github.io` within a few
   minutes — every project link, PDF, and notebook page working directly
   from your own site.

## Using a custom domain later
Buy a domain from any registrar, then add a `CNAME` file to the repo and
point the domain's DNS at GitHub's servers — GitHub's own Pages docs walk
through this when you get there.

## Updating content later
Everything — text, project descriptions, links — lives in plain HTML in
`index.html`. Open it in any text editor (or hand it back to Claude) to
update copy, add a new project block, or swap contact details.
