(import ./bluesky)
(import ./config)
(import ./date)
(import ./github)
(import ./markdown)

(def- nl "\n")
(def- sp " ")

(defn- log
  [& args]
  (when (dyn :quiet) (break))
  (apply prin args)
  (flush))

(defn- make-filter
  [&opt ignores repost? quote-posts?]
  (default ignores [])
  (fn :filter-out [post]
    (def text (post :text))
    (cond
      (or (post :reply?)
          (string/has-prefix? "@" text))
      false
      (and (post :repost?) (not repost?))
      false
      (and (post :quote-post?) (not quote-posts?))
      false
      (some (fn [ignore] (string/find ignore text)) ignores)
      false
      # default
      true)))

(defn make
  "Makes an archive of posts"
  [&named config-file since ignores limit echo? skip-bluesky? skip-github?
   update?]
  (log "Loading configuration from " config-file "...")
  (def config (config/load config-file))
  (log sp "done" nl)
  (def posts @[])
  (if skip-bluesky?
    (log "Skipping pulling from Bluesky... skipped" nl)
    (do
      (def bluesky-config (config :bluesky))
      (log "Authenticating with Bluesky as @" (bluesky-config :handle) "...")
      (def session (bluesky/create-session (bluesky-config :handle)
                                           (bluesky-config :password)))
      (log sp "done" nl)
      (log "Fetching posts...")
      (def actor (session "did"))
      (def since1 (or since (config :last-fetch)))
      (def all-posts (bluesky/fetch-posts session actor since1 limit))
      (log sp (length all-posts) " posts fetched" nl)
      (log "Filtering posts...")
      (def ignores1 (or ignores (config :ignore)))
      (def repost? (config :repost?))
      (def quote-posts? (config :quote-posts?))
      (array/concat posts (filter (make-filter ignores1 repost? quote-posts?) all-posts))
      (log sp (length posts) " posts remaining" nl)
      (when (and echo? (not (empty? posts)))
        (log "Printing posts..." nl)
        (each post posts
          (print (markdown/contents post config)))
        (print "----"))))
  (if skip-github?
    (log "Skipping pushing to GitHub... skipped" nl)
    (if (empty? posts)
      (log "No new posts to upload" nl)
      (do
        (log "Uploading posts to GitHub..." nl)
        (def github-config (config :github))
        (def posts-dir (github-config :posts-dir))
        (each post posts
          (def filename (markdown/filename post))
          (def contents (markdown/contents post config))
          (def path (string posts-dir "/" filename))
          (def uploaded?
            (github/upload-file (github-config :token)
                                (github-config :owner)
                                (github-config :repo)
                                path
                                contents))
          (when uploaded?
            (log sp sp "Uploaded " filename nl))))))
  (when (or update?
            (and (not (empty? posts)) (not skip-github?)))
    (log "Configuration...")
    (def time (if update?
                (-> (os/mktime (os/date)) date/epoch->iso8601)
                ((first posts) :created)))
    (config/save-last-fetch config-file time)
    (log sp "saved" nl))
  (log "Done!" nl))
