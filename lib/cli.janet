(import ../deps/argy-bargy/argy-bargy :as argy)

(import ./archive)
(import ./date)

(def cli-config
  ```
  The configuration for Argy-Bargy
  ```
  {:rules ["--config"     {:kind    :single
                           :short   "c"
                           :default "config.toml"
                           :proxy   "path"
                           :help    "The <path> to the configuration file."}
           "--echo"       {:kind    :flag
                           :short   "e"
                           :help    "Echo post data to stdout."}
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
           "--since"      {:kind    :single
                           :short   "s"
                           :proxy   "date"
                           :help    "Ignore all posts before <date>."}
           "--update"     {:kind    :flag
                           :short   "u"
                           :help    "Force the :last-fetch key in configuration to be updated."}
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

(defn- parse-date
  [s]
  (def time? (or (string/find "T" s) (string/find " " s)))
  (def offset? (or (string/find "Z" s)
                   (string/find "+" s)
                   (string/find "-" s)))
  (def iso? (or (not time?) (string/find "T" s)))
  (def parsef (if iso? date/iso8601->epoch date/rfc2822ish->epoch))
  (def input (cond
               (and time? offset?)
               s
               time?
               (string s (unless iso? " ") (date/local-offset iso?))
               # default
               (string s "T00:00" (date/local-offset iso?))))
  (def [ok? secs] (protect (parsef input)))
  (assertf ok? "unrecognised date '%s' used as value to --since" s)
  secs)

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
  (archive/make :config-file (opts "config")
                :since (-?> (opts "since") (parse-date))
                :ignores (opts "ignore")
                :limit (-?> (opts "limit") (scan-number))
                :echo? (opts "echo")
                :skip-bluesky? (opts "no-bluesky")
                :skip-github? (opts "no-github")
                :update? (opts "update")))

(defn main [& args] (run))
