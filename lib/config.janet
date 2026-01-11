(import ../deps/tomlin)

(import ./date)

(defn- update-last-fetch
  ```
  Updates or adds the last-fetch value in a TOML configuration file.
  ```
  [toml value]
  (def sec-begin (or (and (string/has-prefix? "[" toml) 0)
                     (string/find "\n[" toml)))
  (def top-level (string/slice toml 0 sec-begin))
  (if-let [fetch-begin (string/find "last-fetch = " top-level)
           fetch-end (string/find "\n" top-level fetch-begin)]
    (string (string/slice toml 0 fetch-begin)
            "last-fetch = " value
            (string/slice toml fetch-end))
    (string (string/slice toml 0 sec-begin)
            (when sec-begin "\n")
            "last-fetch = " value
            (when sec-begin "\n")
            (string/slice toml (or sec-begin (length toml))))))

(defn save-last-fetch
  ```
  Updates the last-fetch value in a TOML configuration file on disk.
  ```
  [file-path value]
  (def content (slurp file-path))
  (def updated (update-last-fetch content value))
  (spit file-path updated))

(defn load
  ```
  Loads the TOML configuration file from disk.
  ```
  [file-path]
  (def exists? (= :file (os/stat file-path :mode)))
  (assertf exists? "file %s not found" file-path)
  (def config (-> (slurp file-path) (tomlin/toml->janet)))
  (when (config :last-fetch)
    (def t (config :last-fetch))
    (def iso (string (t :year)
                     "-" (date/min-digits 2 (t :month))
                     "-" (date/min-digits 2 (t :day))
                     "T" (date/min-digits 2 (t :hour))
                     ":" (date/min-digits 2 (t :mins))
                     ":" (date/min-digits 2 (t :secs))
                     "Z"))
    (put config :last-fetch (date/iso8601->epoch iso)))
  config)
