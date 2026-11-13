# The Pear

A no-build HTML/CSS/JavaScript app for rating people on adjustable traits and comparing them on a canvas scatter plot. It uses no UI framework. Supabase JS is used only for authentication and database access.

The hosted app is available at [joecorsi.github.io/thepear/](https://joecorsi.github.io/thepear/).

A retro loading indicator fills in steps as your profile and graphs load, then disappears when loading finishes or fails.

The graph has a black border while it or its axis controls have focus. People expanded by double-clicking them on the graph collapse when you click outside the graph. Focusing or clicking a person's name field selects their visible dot and highlights it with a brief expanding ring unless reduced motion is enabled. The selection remains after the field loses focus, until another person is selected, an axis selector is clicked, or you click outside the graph. A selected person's dot stays in front of other dots. New people have a repeating ring until their dot is moved on the graph by dragging or using the arrow keys; with reduced motion, the ring is stationary. This indicator persists across visits.

Choose a trait pair or age from either end of the square graph's centered, plus-shaped axes. The axis menus show full trait pairs with a dedicated scrollbar; use the arrow keys and Enter to choose one, or Escape to cancel. Each trait has a low end (left or bottom, score 0) and a high end (right or top, score 100); 50 is the midpoint. Age axes span the lowest and highest ages in the list, including hidden people, with a single age centered; people without an age are hidden while an age axis is selected. A fixed white dot marks the center, and the number of plotted people appears beside the People heading. Drag a person's point on the plot to change their scores for the selected X and Y traits, or expand their name to use the sliders, which show the pair's ends on the left and right. Click a point or label to select it, then use the arrow keys to change its scores one step at a time; Escape, clicking an axis selector, or clicking outside the graph clears the selection and highlight. The last clicked name stays in front of other names unless another person is hovered, until another person is clicked, an axis selector is clicked, or Escape is pressed while the graph is focused. Age never changes through dragging or arrow keys; if both axes are age, points cannot be moved. Hover over a name or point to temporarily highlight both with a dotted ring and fade other unselected people; double-click either to find and expand that person in the list. Changes save automatically. When both axes use the same trait, dragging adjusts its single score along the diagonal, and arrow keys change that score. Overlapping points can be separated by dragging the top point.

The workspace stays within the viewport, with the add-person form above the scrollable people list. When displayed side by side, the list ends at the bottom of the graph. Each person's name, optional relationship (Friend, Foe, Lover, or Family), and optional age can be edited in their collapsible row, and new people appear with their sliders collapsed. The relationship dropdown shows **Type** until a relationship is chosen; **Type** is not a selectable option. Use the eye button to hide or show a person on the graph without removing them from the list; visibility is saved with the graph. The X button removes a person after confirmation. Relationships and ages are saved with the graph; existing people remain unclassified until chosen. New people get random plot colors; select a colored circle to choose a color with the color wheel. The arrow keys adjust hue and saturation when the wheel is focused. Use **Options** below the graph to toggle **Color by relationship**, which shows dots and names for friends in green, foes in dark brown, lovers in orange-red, family in purple, and unclassified people in light gray. The **Names** option shows or hides graph labels, and the relationship checkboxes show or hide those groups on the graph without removing them from the list. Unclassified people are unaffected by the relationship checkboxes. These settings are saved separately for each graph. Turning relationship colors off restores everyone's chosen dot colors and black names. The graph menu opens downward; use the arrow keys and Enter to choose a graph, or Escape to cancel. The selected graph's creation and last-saved modification dates appear beside the menu. Use the pencil button to rename the selected graph, the X button to remove it after confirmation, or **New graph** to create another graph. Deleting the last graph creates a new empty one. The status indicator spins while graphs are loading or saving.

When names are shown, hovered and selected graph names appear in a larger raised white box above the axis selectors. An open axis menu appears above the boxes. The hovered box appears above the selected box. Its text and border match the person's relationship color when relationship coloring is enabled; otherwise they are black. Dots and ordinary names underneath a box remain interactive.

Use **Shuffle axes** beside Options to randomly choose two different traits, excluding the current pair. The new axes are saved with the graph. The button is disabled if fewer than two traits are available.

Use **Expand all** to open every currently listed person, or **Collapse all** to close any open people. The people list shows **Scroll for more** when there are entries or trait sliders below the visible area. When a trait slider is focused, use Up and Down to move between that person's sliders and Left and Right to adjust the score. The focused slider is blue.

Expanded people show their added and last-modified dates. Existing people have unknown dates until edited; copying people to another graph preserves their dates. Person edits, including graph movements and visibility changes, update the modified date.

The **Me** row stays below the add-person row and shares your age, color, visibility, and trait scores across your graphs. Me uses its chosen color on the graph even when relationship coloring is enabled; its badge has a gray background and bold text. Click the Me badge to select it on the graph; use the caret to open its sliders, which scroll within the row when needed. You can also adjust its dot on the graph. Its added date uses your account creation date as an approximation of your first login, and its modified date reflects your latest Me edit. Me has no relationship or delete button, is unaffected by search and relationship filters, and is included in Expand all and the All count. Shared scores follow trait IDs: default traits and copied traits share scores, while independently created traits do not, even if their names match. Me is stored separately from graphs and is not copied with graph people.

Use the **Traits** button to add, rename, remove, or swap the ends of traits for the current graph, then choose **Save** or **Cancel**. New traits appear at the top of the list, which scrolls when it exceeds the available dialog height. Swapping ends leaves scores unchanged. Existing traits keep their scores and names as the high end; their low end is shown as "Low" until you name it.

New graphs include the default traits and start with Lame–Cool on the X axis and Benevolent–Malevolent on the Y axis. Changing the defaults does not alter existing saved graphs.

In the New graph dialog, check **Copy people and traits from current graph** to copy its people, ratings, traits, and selected axes into the new graph. The copy is independent of the original; other graph options start at their defaults.

Click the people count to filter the list and graph by relationship, or choose All to clear the filter. Use the arrow keys and Enter to choose a filter, or Escape to cancel. The menu counts include hidden people; the count on the button is the number currently plotted. Use the sort button beside it to order the list by creation order (newest first), name, age (descending, with missing ages last), or visibility (hidden first). Filtering and sorting last until the page is refreshed and do not change saved graph data.

Use **Search people** above the add-person row to filter the list by name as you type; search is case-insensitive and does not change the graph. Use the clear button to show the full list again, subject to the relationship filter. Double-clicking a graph person hidden by search clears the search and opens their row. Search lasts until the page is refreshed and is not saved.

The background selector is currently hidden; the previously selected background remains saved on this device. The Magic Eye pattern hides a heart; relax your gaze to see it.

Each graph is one row in `public.graphs`; its creation time is recorded in `created_at`, and its JSON data contains the people, trait ratings, and selected axes. The shared Me profile is stored in `public.me_profiles`. Row-level security restricts every read and write to the authenticated owner.

## Supabase setup

1. Create a Supabase project.
2. In the Supabase SQL Editor, run [`supabase/schema.sql`](./supabase/schema.sql). Existing installations should rerun it to create the Me profile table and its policies.
3. In **Authentication → Providers**, enable Google and email. Configure Google OAuth credentials in Supabase; the provider secret stays in Supabase and is never entered into this app.
4. In **Authentication → URL Configuration**, set the site URL to `https://joecorsi.github.io/thepear/` and allow that URL as a redirect. For local development, also allow `http://localhost:8000/` and `http://127.0.0.1:8000/`.
5. In this directory, start a static server:

   ```sh
   python3 -m http.server 8000
   ```

6. Open [http://localhost:8000](http://localhost:8000). The app defaults to the existing Supabase project. To use a different project, change `DEFAULT_CONFIG` in `index.html`; existing custom browser settings take precedence. If the connection fails, the connection form appears so it can be corrected.
7. Sign in with Google or request an email magic link.

The app must be served from an allowed HTTP(S) URL; opening `index.html` directly does not provide a valid OAuth redirect origin. For a deployed site, add its URL to Supabase's allowed redirect URLs.

Only the publishable/`anon` key belongs in a browser. Never enter a Supabase `service_role` or secret key. Custom connection values are saved in that browser's local storage and override the built-in defaults; graph data is saved in Supabase and protected by the table's row-level security policies. Sessions are separate in each browser, so sign in again when using another browser.
