(import ../deps/argy-bargy/argy-bargy :as argy)

(import ./bluesky)
(import ./config)
(import ./date)
(import ./github)
(import ./markdown)

(def cli-config
  ```
  The configuration for Argy-Bargy
  ```
  {:rules ["--config"     {:kind    :single
                           :short   "c"
                           :default "config.jdn"
                           :proxy   "path"
                           :help    "The <path> to the configuration file."}
           "--ignore"     {:kind    :multi
                           :short   "i"
                           :proxy   "string"
                           :help    "Posts that include <string> are ignored."}
           "--limit"      {:kind    :single
                           :short   "l"
                           :help    "Limit the number of posts to <limit>."}
           "--quiet"      {:kind    :flag
                           :short   "q"
                           :help    "Silence output."}
           "--no-bluesky" {:kind    :flag
                           :short   "B"
                           :hide?   true
                           :help    "Do not pull from Bluesky."}
           "--no-github"  {:kind    :flag
                           :short   "G"
                           :hide?   true
                           :help    "Do not push to GitHub."}
           "-------------------------------------------"]
   :info {:about "Archive Bluesky posts to a GitHub repository as Markdown files."}})

(dyn :quiet false)

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

(defn- archive
  [opts]
  (def config-file (opts "config"))
  (log "Loading configuration from " config-file "...")
  (def config (load-file config-file))
  (log sp "done" nl)
  (def posts @[])
  (if (opts "no-bluesky")
    (log "Skipping pulling from Bluesky..." nl)
    (do
      (log "Authenticating with Bluesky...")
      (def bluesky-config (config :bluesky))
      (def session (bluesky/create-session (bluesky-config :handle)
                                           (bluesky-config :password)))
      (log sp (session "handle") nl)
      (log "Fetching posts...")
      (def actor (session "did"))
      (def limit (-?> (opts "limit") (scan-number)))
      (def all-posts (bluesky/fetch-posts session actor (config :last-fetch) limit))
      (log sp (length all-posts) " posts" nl)
      (log "Filtering posts...")
      (array/concat posts (filter (make-filter (opts "ignore")) all-posts))
      (log sp (length posts) " posts" nl)))
  (if (opts "no-github")
    (log "Skipping pushing to GitHub..." nl)
    (do
      (if (zero? (length posts))
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
        (def most-recent-epoch (date/as-epoch most-recent))
        (def ds (config/jdn-str->jdn-arr (slurp config-file)))
        (if (has-key? config :last-fetch)
          (config/upd-in ds [:last-fetch] :to most-recent-epoch)
          (config/add-to ds [:last-fetch] most-recent-epoch))
        (spit config-file (config/jdn-arr->jdn-str ds))))))
  (log "Done!" nl))

(defn run
  []
  (def parsed (argy/parse-args "blues" cli-config))
  (def err (parsed :err))
  (def help (parsed :help))
  (cond
    (not (empty? help))
    (do
      (prin help)
      (os/exit (if (get-in parsed [:opts "help"]) 0 1)))
    (not (empty? err))
    (do
      (eprin err)
      (os/exit 1)))
  (def opts (parsed :opts))
  (setdyn :quiet (opts "quiet"))
  (archive opts))

(defn main [& args] (run))
