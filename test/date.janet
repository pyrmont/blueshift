(use ../deps/testament)

(import ../lib/date :as d)

# Tests for local-offset
(deftest local-offset-format
  (def offset (d/local-offset))
  (is (or (= offset "+0000")
          (and (string/has-prefix? "+" offset)
               (= 5 (length offset)))
          (and (string/has-prefix? "-" offset)
               (= 5 (length offset))))))

(deftest local-offset-iso-format
  (def offset (d/local-offset true))
  (is (or (= offset "+0000")
          (and (string/has-prefix? "+" offset)
               (= 6 (length offset))
               (string/find ":" offset))
          (and (string/has-prefix? "-" offset)
               (= 6 (length offset))
               (string/find ":" offset)))))

# Tests for iso8601->epoch
(deftest iso8601->epoch-simple-utc
  (def input "2024-01-15T12:30:45Z")
  (is (== 1705321845 (d/iso8601->epoch input))))

(deftest iso8601->epoch-with-milliseconds
  (def input "2024-01-15T12:30:45.123Z")
  (is (== 1705321845 (d/iso8601->epoch input))))

(deftest iso8601->epoch-with-positive-offset
  (def input "2024-01-15T12:30:45+05:00")
  (is (== 1705303845 (d/iso8601->epoch input))))

(deftest iso8601->epoch-with-negative-offset
  (def input "2024-01-15T12:30:45-0500")
  (is (== 1705339845 (d/iso8601->epoch input))))

(deftest iso8601->epoch-date-only
  (def input "2024-01-15")
  (is (== 1705276800 (d/iso8601->epoch input))))

# Tests for iso8601->rfc2822ish
(deftest iso8601->rfc2822ish-simple-utc
  (def input "2024-01-15T12:30:45Z")
  (def expect "2024-01-15 12:30:45 +0000")
  (is (== expect (d/iso8601->rfc2822ish input))))

(deftest iso8601->rfc2822ish-with-milliseconds
  (def input "2024-01-15T12:30:45.123Z")
  (def expect "2024-01-15 12:30:45 +0000")
  (is (== expect (d/iso8601->rfc2822ish input))))

(deftest iso8601->rfc2822ish-with-positive-offset
  (def input "2024-01-15T12:30:45+05:30")
  (def expect "2024-01-15 12:30:45 +0530")
  (is (== expect (d/iso8601->rfc2822ish input))))

(deftest iso8601->rfc2822ish-with-negative-offset
  (def input "2024-01-15T12:30:45-08:00")
  (def expect "2024-01-15 12:30:45 -0800")
  (is (== expect (d/iso8601->rfc2822ish input))))

(deftest iso8601->rfc2822ish-date-only
  (def input "2024-01-15")
  (def expect "2024-01-15")
  (is (== expect (d/iso8601->rfc2822ish input))))

(deftest iso8601->rfc2822ish-no-seconds
  (def input "2024-01-15T12:30Z")
  (def expect "2024-01-15 12:30 +0000")
  (is (== expect (d/iso8601->rfc2822ish input))))

# Tests for rfc2822ish->epoch
(deftest rfc2822ish->epoch-simple-utc
  (def input "2024-01-15 12:30:45 +0000")
  (is (== 1705321845 (d/rfc2822ish->epoch input))))

(deftest rfc2822ish->epoch-with-positive-offset
  (def input "2024-01-15 12:30:45 +0530")
  (is (== 1705302045 (d/rfc2822ish->epoch input))))

(deftest rfc2822ish->epoch-with-negative-offset
  (def input "2024-01-15 12:30:45 -0800")
  (is (== 1705350645 (d/rfc2822ish->epoch input))))

(deftest rfc2822ish->epoch-date-only
  (def input "2024-01-15")
  (is (== 1705276800 (d/rfc2822ish->epoch input))))

(deftest rfc2822ish->epoch-no-seconds
  (def input "2024-01-15 12:30 +0000")
  (is (== 1705321800 (d/rfc2822ish->epoch input))))

# Tests for rfc2822ish->iso8601
(deftest rfc2822ish->iso8601-simple-utc
  (def input "2024-01-15 12:30:45 +0000")
  (def expect "2024-01-15T12:30:45+0000")
  (is (== expect (d/rfc2822ish->iso8601 input))))

(deftest rfc2822ish->iso8601-with-positive-offset
  (def input "2024-01-15 12:30:45 +0530")
  (def expect "2024-01-15T12:30:45+0530")
  (is (== expect (d/rfc2822ish->iso8601 input))))

(deftest rfc2822ish->iso8601-with-negative-offset
  (def input "2024-01-15 12:30:45 -0800")
  (def expect "2024-01-15T12:30:45-0800")
  (is (== expect (d/rfc2822ish->iso8601 input))))

(deftest rfc2822ish->iso8601-date-only
  (def input "2024-01-15")
  (def expect "2024-01-15")
  (is (== expect (d/rfc2822ish->iso8601 input))))

(deftest rfc2822ish->iso8601-no-seconds
  (def input "2024-01-15 12:30 +0000")
  (def expect "2024-01-15T12:30+0000")
  (is (== expect (d/rfc2822ish->iso8601 input))))

# Round-trip tests
(deftest roundtrip-iso-to-rfc-to-iso
  (def original "2024-01-15T12:30:45+05:30")
  (def rfc (d/iso8601->rfc2822ish original))
  (def back (d/rfc2822ish->iso8601 rfc))
  (is (== back "2024-01-15T12:30:45+0530")))

(deftest roundtrip-via-epoch
  (def iso-input "2024-01-15T12:30:45+05:30")
  (def rfc-input "2024-01-15 12:30:45 +0530")
  (def iso-epoch (d/iso8601->epoch iso-input))
  (def rfc-epoch (d/rfc2822ish->epoch rfc-input))
  (is (== iso-epoch rfc-epoch)))

(run-tests!)
