(use ../deps/testament)

(import ../lib/base64 :as b64)

(deftest encode-empty-string
  (def input "")
  (def expect "")
  (is (== expect (b64/encode input))))

(deftest encode-single-char
  (def input "A")
  (def expect "QQ==")
  (is (== expect (b64/encode input))))

(deftest encode-two-chars
  (def input "AB")
  (def expect "QUI=")
  (is (== expect (b64/encode input))))

(deftest encode-three-chars
  (def input "ABC")
  (def expect "QUJD")
  (is (== expect (b64/encode input))))

(deftest encode-simple-text
  (def input "Hello")
  (def expect "SGVsbG8=")
  (is (== expect (b64/encode input))))

(deftest encode-longer-text
  (def input "Hello, World!")
  (def expect "SGVsbG8sIFdvcmxkIQ==")
  (is (== expect (b64/encode input))))

(deftest encode-with-special-chars
  (def input "user:pass")
  (def expect "dXNlcjpwYXNz")
  (is (== expect (b64/encode input))))

(deftest encode-binary-data
  (def input @[0 1 2 3 4 5])
  (def result (b64/encode input))
  (is (string? result))
  (is (> (length result) 0)))

(run-tests!)
