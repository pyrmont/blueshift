(defn- parse-iso8601
  "Parse ISO 8601 timestamp into components"
  [iso-string]
  (def parts (string/split "T" iso-string))
  (def date-part (parts 0))
  (def time-part (parts 1))
  (def date-bits (string/split "-" date-part))
  (def year (scan-number (date-bits 0)))
  (def month (scan-number (date-bits 1)))
  (def day (scan-number (date-bits 2)))
  (def time-bits (string/split ":" time-part))
  (def hours (time-bits 0))
  (def minutes (time-bits 1))
  (def seconds-raw (time-bits 2))
  (def seconds-no-ms (if (def pos (string/find "." seconds-raw))
                       (string/slice seconds-raw 0 pos)
                       seconds-raw))
  (def seconds
    (cond
      (string/find "Z" seconds-no-ms)
      (string/slice seconds-no-ms 0 (string/find "Z" seconds-no-ms))
      (string/find "+" seconds-no-ms)
      (string/slice seconds-no-ms 0 (string/find "+" seconds-no-ms))
      (and (string/find "-" seconds-no-ms) (> (length seconds-no-ms) 2))
      (string/slice seconds-no-ms 0 (string/find "-" seconds-no-ms))
      # default
      seconds-no-ms))
  (def tz-offset-str
    (cond
      (string/find "Z" time-part)
      "+0000"
      (string/find "+" time-part)
      (do
        (def offset-raw (last (string/split "+" time-part)))
        (string "+" (string/replace-all ":" "" offset-raw)))
      (string/find "-" time-part)
      (do
        (def offset-raw (last (string/split "-" time-part)))
        (string "-" (string/replace-all ":" "" offset-raw)))
      # default
      "+0000"))
  (def tz-offset-seconds
    (if (= tz-offset-str "+0000")
      0
      (do
        (def sign (if (string/has-prefix? "+" tz-offset-str) 1 -1))
        (def offset-num (string/slice tz-offset-str 1))
        (def offset-hours (scan-number (string/slice offset-num 0 2)))
        (def offset-mins (scan-number (string/slice offset-num 2 4)))
        (* sign (+ (* 3600 offset-hours) (* 60 offset-mins))))))
  {:date-part date-part
   :year year
   :month month
   :day day
   :hours hours
   :minutes minutes
   :seconds seconds
   :tz-offset-str tz-offset-str
   :tz-offset-seconds tz-offset-seconds})

(defn as-epoch
  "Convert ISO 8601 timestamp to Unix epoch seconds (UTC)"
  [iso-string]
  (def parsed (parse-iso8601 iso-string))
  (def date-struct {:year (parsed :year)
                    :month (dec (parsed :month))
                    :month-day (dec (parsed :day))
                    :hours (scan-number (parsed :hours))
                    :minutes (scan-number (parsed :minutes))
                    :seconds (scan-number (parsed :seconds))})
  # os/mktime without 'local' parameter interprets date as UTC
  (- (os/mktime date-struct) (parsed :tz-offset-seconds)))

(defn as-quasi-rfc2822
  "Convert ISO 8601 datetime to YYYY-MM-DD HH:MM:SS +ZZZZ format"
  [iso-string]
  (def parsed (parse-iso8601 iso-string))
  (string (parsed :date-part) " "
          (parsed :hours) ":"
          (parsed :minutes) ":"
          (parsed :seconds) " "
          (parsed :tz-offset-str)))
