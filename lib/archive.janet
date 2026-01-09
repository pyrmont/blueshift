(import ./bluesky)
(import ./config)
(import ./date)
(import ./github)
(import ./markdown)

(def- nl "\n")
(def- sp " ")

(defn- load-file
  [file]
  (def exists? (= :file (os/stat file :mode)))
  (assertf exists? "file %s not found" file)
  (-> (slurp file) parse))

(defn- log
  [& args]
  (when (dyn :quiet) (break))
  (apply prin args)
  (flush))

(defn- make-filter
  [&opt ignores]
  (default ignores [])
  (fn :filter-out [post]
    (def text (post :text))
    (cond
      (or (post :repost?)
          (post :reply?)
          (post :quote-post?)
          (string/has-prefix? "@" text))
      false
      (some (fn [ignore] (string/find ignore text)) ignores)
      false
      # default
      true)))

(defn make
  "Makes an archive of posts"
  [&named config-file since ignores limit echo? skip-bluesky? skip-github?]
  (log "Loading configuration from " config-file "...")
  (def config (load-file config-file))
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
      (array/concat posts (filter (make-filter ignores1) all-posts))
      (log sp (length posts) " posts remaining" nl)
      (when (and echo? (not (empty? posts)))
        (log "Printing posts..." nl)
        (each post posts
          (print "----")
          (print (post :created))
          (print (post :text)))
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
          (def contents (markdown/contents post))
          (def path (string posts-dir "/" filename))
          (def uploaded?
            (github/upload-file (github-config :token)
                                (github-config :owner)
                                (github-config :repo)
                                path
                                contents))
          (when uploaded?
            (log sp sp "Uploaded " filename nl)))
        (def most-recent ((first posts) :created))
        (def most-recent-epoch (date/iso8601->epoch most-recent))
        (def ds (config/jdn-str->jdn-arr (slurp config-file)))
        (if (has-key? config :last-fetch)
          (config/upd-in ds [:last-fetch] :to most-recent-epoch)
          (config/add-to ds [:last-fetch] most-recent-epoch))
        (spit config-file (config/jdn-arr->jdn-str ds)))))
  (log "Done!" nl))

