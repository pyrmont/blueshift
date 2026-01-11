(import ./date)

(def- nl "\n")

(defn- facet-to-markdown
  "Convert a facet feature to markdown syntax"
  [text byte-start byte-end features]
  (def original-text (string/slice text byte-start byte-end))
  (def feature (first features))
  (def feature-type (get feature "$type"))
  (cond
    (= feature-type "app.bsky.richtext.facet#link")
    (string "[" original-text "](" (feature "uri") ")")
    (= feature-type "app.bsky.richtext.facet#mention")
    (string "[" original-text "](https://bsky.app/profile/" (feature "did") ")")
    (= feature-type "app.bsky.richtext.facet#tag")
    (string "[" original-text "](https://bsky.app/hashtag/" (feature "tag") ")")
    # default (return original text if unknown facet type)
    original-text))

(defn- decorate-text
  "Apply facets to decorate text with markdown links"
  [text facets]
  (when (or (nil? facets) (empty? facets))
    (break text))
  # Sort facets by byte position in forward order
  (def sorted-facets (sorted facets
                             (fn [a b]
                               (def start-a (get-in a ["index" "byteStart"]))
                               (def start-b (get-in b ["index" "byteStart"]))
                               (< start-a start-b))))
  # Build result using a buffer
  (def buf @"")
  (var pos 0)
  (each facet sorted-facets
    (def byte-start (get-in facet ["index" "byteStart"]))
    (def byte-end (get-in facet ["index" "byteEnd"]))
    (def features (facet "features"))
    (when (and byte-start byte-end features)
      # Add text before this facet
      (buffer/push buf (string/slice text pos byte-start))
      # Add markdown-decorated text
      (buffer/push buf (facet-to-markdown text byte-start byte-end features))
      # Update position
      (set pos byte-end)))
  # Add any remaining text after the last facet
  (buffer/push buf (string/slice text pos))
  (string buf))

(defn- create-slug
  "Create a slug from post text by finding first word > 7 chars or joining words with dashes"
  [text]
  (def words (string/split " " text))
  (var slug "")
  (def long-word (find (fn [w] (> (length w) 7)) words))
  (if long-word
    (set slug long-word)
    (do
      (var word-list @[])
      (var len 0)
      (var i 0)
      (while (and (< i (length words)) (<= len 7))
        (array/push word-list (words i))
        (+= len (length (words i)))
        (++ i))
      (set slug (string/join word-list "-"))))
  (def buf @"")
  (each char slug
    (when (or (and (>= char (chr "a")) (<= char (chr "z")))
              (and (>= char (chr "A")) (<= char (chr "Z")))
              (and (>= char (chr "0")) (<= char (chr "9")))
              (= char (chr "-")))
      (buffer/push-byte buf char)))
  (def full-slug (string/ascii-lower buf))
  (if (> (length full-slug) 20)
    (string/slice full-slug 0 20)
    full-slug))

(defn- format-frontmatter
  "Create YAML-style frontmatter for the Markdown file"
  [data opts]
  (def buf @"")
  (def epoch (date/iso8601->epoch (data :created)))
  (def format (get opts :date-format "iso8601"))
  (def date (case format
              "iso8601" (date/epoch->iso8601 epoch (opts :time-offset))
              "rfc2822ish" (date/epoch->rfc2822ish epoch (opts :time-offset))
              (errorf "unrecognised date format: %s" format)))
  (buffer/push buf "---" nl)
  (buffer/push buf "date: " date nl)
  (buffer/push buf "source: " (data :uri) nl)
  (when (data :repost?)
    (buffer/push buf "repost: true" nl))
  (when (data :quote-post?)
    (buffer/push buf "quote-post: true" nl))
  (when (data :ref)
    (buffer/push buf "ref: " (data :ref) nl))
  (when-let [links (get-in data [:embeds :links])]
    (each ln links
      (buffer/push buf "link:" nl)
      (buffer/push buf "  url: " (ln :uri) nl)
      (when (ln :title)
        (buffer/push buf "  title: " (ln :title) nl))
      (when (ln :desc)
        (if (string/find "\n" (ln :desc))
          # Multi-line description: use literal block scalar
          (do
            (buffer/push buf "  desc: |" nl)
            (each line (string/split "\n" (ln :desc))
              (buffer/push buf "    " line nl)))
          # Single-line description
          (buffer/push buf "  desc: " (ln :desc) nl)))
      (when (ln :thumb)
        (buffer/push buf "  thumb: " (ln :thumb) nl))))
  (buffer/push buf "---" nl)
  (string buf))

(defn- format-embeds
  "Format embedded images"
  [embed]
  (def b @"")
  (when (def images (embed :images))
    (each img images
      (buffer/push b nl)
      (buffer/push b "!["
                     (or (img :title) "Image")
                     "]("
                     (img :uri)
                     ")")
      (buffer/push b nl)))
  (string b))

(defn contents
  [data &opt opts]
  (default opts {})
  (def frontmatter (format-frontmatter data opts))
  (def body (decorate-text (data :text) (data :facets)))
  (def embeds (format-embeds (data :embeds)))
  (string frontmatter nl body nl embeds))

(defn filename
  [data]
  (def slug (create-slug (data :text)))
  (def date (first (string/split "T" (data :created))))
  (string date "-" slug ".md"))
