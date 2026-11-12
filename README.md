# The Pear

A no-build HTML/CSS/JavaScript app for rating people on adjustable traits and comparing them on a canvas scatter plot. It uses no UI framework. Supabase JS is used only for authentication and database access.

Choose a trait pair from either end of the graph's centered, plus-shaped axes. The axis menus show full trait pairs; use the arrow keys and Enter to choose one, or Escape to cancel. Each trait has a low end (left or bottom, score 0) and a high end (right or top, score 100); 50 is the midpoint. A fixed white dot marks the center, and the number of people appears below the graph. Drag a person's point on the plot to change their scores for the selected X and Y traits, or expand their name to use the sliders, which show the pair's ends on the left and right. Hover over a name or point to highlight both with a dotted ring and fade the others; double-click either to find and expand that person in the list. Changes save automatically. When both axes use the same trait, dragging adjusts its single score along the diagonal. Overlapping points can be separated by dragging the top point.

The workspace stays within the viewport, with the add-person form above the scrollable people list. Each person's name can be edited in their collapsible row, and new people appear at the top with their sliders expanded. New people get random plot colors; select a colored circle to choose a color with the color wheel. The arrow keys adjust hue and saturation when the wheel is focused. The graph menu opens downward; use the arrow keys and Enter to choose a graph, or Escape to cancel. The selected graph's creation date appears beside the menu. Use **Rename** to rename the selected graph, **Delete** to remove it after confirmation, or **New graph** to create another graph. Deleting the last graph creates a new empty one.

Use the **Traits** button to add, rename, remove, or swap the ends of traits for the current graph, then choose **Save** or **Cancel**. Swapping ends leaves scores unchanged. Existing traits keep their scores and names as the high end; their low end is shown as "Low" until you name it.

The background selector is currently hidden; the previously selected background remains saved on this device. The Magic Eye pattern hides a heart; relax your gaze to see it.

Each graph is one row in `public.graphs`; its creation time is recorded in `created_at`, and its JSON data contains the people, trait ratings, and selected axes. Row-level security restricts every read and write to the authenticated owner.

## Supabase setup

1. Create a Supabase project.
2. In the Supabase SQL Editor, run [`supabase/schema.sql`](./supabase/schema.sql).
3. In **Authentication → Providers**, enable Google and email. Configure Google OAuth credentials in Supabase; the provider secret stays in Supabase and is never entered into this app.
4. In **Authentication → URL Configuration**, set the site's URL and allow the app's redirect URL. For local development, use `http://localhost:8000`.
5. In this directory, start a static server:

   ```sh
   python3 -m http.server 8000
   ```

6. Open [http://localhost:8000](http://localhost:8000). The app defaults to the existing Supabase project. To use a different project, change `DEFAULT_CONFIG` in `index.html`; existing custom browser settings take precedence. If the connection fails, the connection form appears so it can be corrected.
7. Sign in with Google or request an email magic link.

The app must be served from an allowed HTTP(S) URL; opening `index.html` directly does not provide a valid OAuth redirect origin. For a deployed site, add its URL to Supabase's allowed redirect URLs.

Only the publishable/`anon` key belongs in a browser. Never enter a Supabase `service_role` or secret key. Custom connection values are saved in that browser's local storage and override the built-in defaults; graph data is saved in Supabase and protected by the table's row-level security policies. Sessions are separate in each browser, so sign in again when using another browser.
