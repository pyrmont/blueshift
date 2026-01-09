(import ./date)

(def- nl "\n")

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
  [data]
  (string
    "---" nl
    "date: " (date/iso8601->rfc2822ish (data :created)) nl
    "source: " (data :uri) nl
    "---" nl))

(defn- format-embeds
  "Format embedded content (images and links)"
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
  (when (def links (embed :links))
    (each ln links
      (buffer/push b nl)
      (buffer/push b "["
                     (ln :title)
                     "]"
                     "("
                     (ln :uri)
                     ")")
      (buffer/push b nl)))
  (string b))

(defn contents
  [data]
  (def frontmatter (format-frontmatter data))
  (def embeds (format-embeds (data :embeds)))
  (string frontmatter nl (data :text) nl embeds))

(defn filename
  [data]
  (def slug (create-slug (data :text)))
  (def date (first (string/split "T" (data :created))))
  (string date "-" slug ".md"))
