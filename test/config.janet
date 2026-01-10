(use ../deps/testament)

(review ../lib/config :as c)

(deftest update-last-fetch-empty-file
  (def input "")
  (def result (c/update-last-fetch input 123))
  (is (string/find "last-fetch = 123" result)))

(deftest update-last-fetch-add-to-existing
  (def input "[bluesky]\nhandle = \"test\"")
  (def result (c/update-last-fetch input 456))
  (is (string/find "[bluesky]" result))
  (is (string/find "last-fetch = 456" result))
  # Verify last-fetch comes before the section
  (def lf-pos (string/find "last-fetch" result))
  (def section-pos (string/find "[bluesky]" result))
  (is (< lf-pos section-pos)))

(deftest update-last-fetch-update-existing
  (def input "last-fetch = 100\n\n[bluesky]\nhandle = \"test\"")
  (def result (c/update-last-fetch input 789))
  (is (string/find "last-fetch = 789" result))
  (is (not (string/find "last-fetch = 100" result))))

(deftest update-last-fetch-preserves-content
  (def input "[bluesky]\nhandle = \"test\"\npassword = \"secret\"")
  (def result (c/update-last-fetch input 999))
  (is (string/find "handle = \"test\"" result))
  (is (string/find "password = \"secret\"" result))
  (is (string/find "last-fetch = 999" result))
  # Verify last-fetch comes before the section
  (def lf-pos (string/find "last-fetch" result))
  (def section-pos (string/find "[bluesky]" result))
  (is (< lf-pos section-pos)))

(deftest update-last-fetch-with-whitespace
  (def input "  last-fetch = 100\n\n[bluesky]\nhandle = \"test\"")
  (def result (c/update-last-fetch input 200))
  (is (string/find "last-fetch = 200" result))
  (is (not (string/find "last-fetch = 100" result))))

(run-tests!)
