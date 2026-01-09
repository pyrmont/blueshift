(defn- min-digits
  "Creates a string that is at least the minimum number of digits"
  [min-len n]
  (def s (string n))
  (string (string/repeat "0" (max 0 (- min-len (length s)))) s))

(defn- offset-str->secs
  "Converts an offset string to seconds"
  [offset-str]
  (when (nil? offset-str)
    (break))
  (when ({"Z" true "+0000" "-0000"} offset-str)
    (break 0))
  (def sign (if (string/has-prefix? "+" offset-str) 1 -1))
  (def hrs (scan-number (string/slice offset-str 1 3)))
  (def mins (scan-number (string/slice offset-str 3 5)))
  (* sign (+ (* 3600 hrs) (* 60 mins))))

(defn- parse-rfc2822ish
  "Parses RFC 2822ish timestamp into components"
  [rfc-string]
  (def res (peg/match ~{:main (* :date (? :time) -1)
                        :date (* :year "-" :month "-" :day)
                        :year (* (constant :year) (number (4 :d)))
                        :month (* (constant :month) (number (2 :d)))
                        :day (* (constant :day) (number (2 :d)))
                        :time (* (? " ") :hrs ":" :mins (? (* ":" :secs)) (? :offset))
                        :hrs (* (constant :hours) (number (between 1 2 :d)))
                        :mins (* (constant :minutes) (number (2 :d)))
                        :secs (* (constant :seconds) (number (2 :d)))
                        :offset (* (constant :offset) (? " ") '(* (+ "+" "-") (4 :d)))}
                      rfc-string))
  (assertf (not (nil? res)) "invalid date %s" rfc-string)
  (def t (table ;res))
  (merge t {:offset-secs (offset-str->secs (t :offset))}))

(defn- parse-iso8601
  "Parses ISO 8601 timestamp into components"
  [iso-string]
  (def res (peg/match ~{:main (* :date (? :time) -1)
                        :date (* :year "-" :month "-" :day)
                        :year (* (constant :year) (number (4 :d)))
                        :month (* (constant :month) (number (2 :d)))
                        :day (* (constant :day) (number (2 :d)))
                        :time (* "T" :hrs ":" :mins (? (* ":" :secs (? (* "." :ms)))) (? :offset))
                        :hrs (* (constant :hours) (number (between 1 2 :d)))
                        :mins (* (constant :minutes) (number (2 :d)))
                        :secs (* (constant :seconds) (number (2 :d)))
                        :ms :d+
                        :offset (* (constant :offset) (+ (* (constant "+0000") "Z")
                                                         (% (* '(+ "+" "-") '(2 :d) (? ":") '(2 :d)))))}
                      iso-string))
  (assertf (not (nil? res)) "invalid date %s" iso-string)
  (def t (table ;res))
  (merge t {:offset-secs (offset-str->secs (t :offset))}))

# Public functions

(defn local-offset
  "Calculates the offset of the local timezone"
  [&opt iso?]
  (def secs (os/mktime (os/date 0 true)))
  (when (zero? secs)
    (break "+0000"))
  (def abs-secs (math/abs secs))
  (def hrs (math/floor (/ abs-secs 3600)))
  (def mins (* 60 (- (/ abs-secs 3600) hrs)))
  (string (if (> secs 0) "+" "-")
          (min-digits 2 hrs)
          (when iso? ":")
          (min-digits 2 mins)))

(defn iso8601->epoch
  "Converts ISO 8601 timestamp to Unix epoch seconds (UTC)"
  [iso-string]
  (def t (parse-iso8601 iso-string))
  (def date-struct {:year (t :year)
                    :month (dec (t :month))
                    :month-day (dec (t :day))
                    :hours (t :hours)
                    :minutes (t :minutes)
                    :seconds (t :seconds)})
  (- (os/mktime date-struct) (get t :offset-secs 0)))

(defn iso8601->rfc2822ish
  "Converts ISO 8601 datetime to an RFC 2822ish datetime"
  [iso-string]
  (def t (parse-iso8601 iso-string))
  (def date (string (t :year) "-"
                    (min-digits 2 (t :month)) "-"
                    (min-digits 2 (t :day))))
  (def time (cond
              (and (t :hours) (t :seconds))
              (string " " (min-digits 2 (t :hours))
                      ":" (min-digits 2 (t :minutes))
                      ":" (min-digits 2 (t :seconds)))
              (and (t :hours) (t :minutes))
              (string " " (min-digits 2 (t :hours))
                      ":" (min-digits 2 (t :minutes)))))
  (def offset (when (t :offset) (string " " (t :offset))))
  (string date time offset))

(defn rfc2822ish->epoch
  "Converts RFC 2822ish datetime to Unix epoch seconds (UTC)"
  [rfc-string]
  (def t (parse-rfc2822ish rfc-string))
  (def date-struct {:year (t :year)
                    :month (dec (t :month))
                    :month-day (dec (t :day))
                    :hours (t :hours)
                    :minutes (t :minutes)
                    :seconds (t :seconds)})
  (- (os/mktime date-struct) (get t :offset-secs 0)))

(defn rfc2822ish->iso8601
  "Converts RFC 2822ish datetime to ISO 8601 datetime"
  [rfc-string]
  (def t (parse-rfc2822ish rfc-string))
  (def date (string (t :year) "-"
                    (min-digits 2 (t :month)) "-"
                    (min-digits 2 (t :day))))
  (def time (cond
              (and (t :hours) (t :seconds))
              (string "T" (min-digits 2 (t :hours))
                      ":" (min-digits 2 (t :minutes))
                      ":" (min-digits 2 (t :seconds)))
              (and (t :hours) (t :minutes))
              (string "T" (min-digits 2 (t :hours))
                      ":" (min-digits 2 (t :minutes)))))
  (def offset (when (t :offset) (t :offset)))
  (string date time offset))
