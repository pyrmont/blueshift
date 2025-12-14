(use ../deps/testament)

(import ../lib/date :as d)

(deftest as-epoch-simple-utc
  (def input "2024-01-15T12:30:45Z")
  (is (== 1705321845 (d/as-epoch input))))

(deftest as-epoch-with-milliseconds
  (def input "2024-01-15T12:30:45.123Z")
  (is (== 1705321845 (d/as-epoch input))))

(deftest as-epoch-with-positive-offset
  (def input "2024-01-15T12:30:45+05:00")
  (is (== 1705303845 (d/as-epoch input))))

(deftest as-epoch-with-negative-offset
  (def input "2024-01-15T12:30:45-05:00")
  (is (== 1705339845 (d/as-epoch input))))

(deftest as-quasi-rfc2822-simple-utc
  (def input "2024-01-15T12:30:45Z")
  (def expect "2024-01-15 12:30:45 +0000")
  (is (== expect (d/as-quasi-rfc2822 input))))

(deftest as-quasi-rfc2822-with-milliseconds
  (def input "2024-01-15T12:30:45.123Z")
  (def expect "2024-01-15 12:30:45 +0000")
  (is (== expect (d/as-quasi-rfc2822 input))))

(deftest as-quasi-rfc2822-with-positive-offset
  (def input "2024-01-15T12:30:45+05:30")
  (def expect "2024-01-15 12:30:45 +0530")
  (is (== expect (d/as-quasi-rfc2822 input))))

(deftest as-quasi-rfc2822-with-negative-offset
  (def input "2024-01-15T12:30:45-08:00")
  (def expect "2024-01-15 12:30:45 -0800")
  (is (== expect (d/as-quasi-rfc2822 input))))

(run-tests!)
