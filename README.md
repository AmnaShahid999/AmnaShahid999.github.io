# Portfolio site — deploy to GitHub Pages (free)

1. In your GitHub account, create a new repository named `amnashahid999.github.io`
   (must match your username exactly — this gives you a live URL with no extra setup).
2. Upload these 4 files to the **root** of that repository, all together, no
   subfolders needed:
   - `index.html`
   - `qsli-framework.pdf`
   - `course-evaluation-response-rate-analysis.pdf`
   - `dlcp-dashboard.twbx`

   (drag-and-drop works on github.com under "Add file → Upload files", or
   `git add / commit / push` if you're using the command line)
3. Go to the repo's **Settings → Pages** and confirm the source is set to
   your default branch (check the branch name shown just above the file
   list on the repo's main page — it'll say `main` or `master`), root
   folder. Click Save.
4. Your site will be live at `https://amnashahid999.github.io` within a few
   minutes.

## Second step: upload notebooks to your existing "Projects" repo

The site links to five Jupyter notebooks (thesis pipeline + admissions
project) using GitHub's own notebook viewer, since it renders `.ipynb` files
far better than a flat file download would. For those links to work:

1. Go to your existing repo at `github.com/AmnaShahid999/Projects`.
2. Upload the five files from the `for-github-projects-repo/` folder you were
   given, **keeping these exact filenames**:
   - `thesis-1-data-preprocessing.ipynb`
   - `thesis-2-unsupervised-learning.ipynb`
   - `thesis-3-supervised-learning.ipynb`
   - `admissions-1-data-cleaning.ipynb`
   - `admissions-2-enrollment-segmentation.ipynb`
3. If they land somewhere other than the repo root (e.g. inside a subfolder),
   update the matching links in `index.html` to include that folder in the
   path.

## Using a custom domain later
Buy a domain from any registrar, then add a `CNAME` file to the repo and
point the domain's DNS at GitHub's servers — GitHub's own Pages docs walk
through this when you get there.

## Updating content later
Everything — text, project descriptions, links — lives in plain HTML in
`index.html`. Open it in any text editor (or hand it back to Claude) to
update copy, add a new project block, or swap contact details.
