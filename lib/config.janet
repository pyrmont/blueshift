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
