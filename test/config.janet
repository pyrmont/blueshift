(use ../deps/testament)

(import ../lib/config :as c)

(deftest jdn-str-to-arr-empty-dict
  (def input "{}")
  (def result (c/jdn-str->jdn-arr input))
  (is (== @[@["{" "}"]] result)))

(deftest jdn-str-to-arr-simple-dict
  (def input "{:foo \"bar\"}")
  (def result (c/jdn-str->jdn-arr input))
  (is (array? result))
  (def dict (first result))
  (is (== "{" (first dict))))

(deftest jdn-arr-to-str-empty-dict
  (def input @[@["{" "}"]])
  (def result (c/jdn-arr->jdn-str input))
  (is (== "{}" result)))

(deftest jdn-roundtrip
  (def original "{:foo \"bar\"\n :baz 42}")
  (def arr (c/jdn-str->jdn-arr original))
  (def result (c/jdn-arr->jdn-str arr))
  (is (== original result)))

(deftest add-to-empty-dict
  (def jdn "{}")
  (def ds (c/jdn-str->jdn-arr jdn))
  (c/add-to ds [:test] 123)
  (def result (c/jdn-arr->jdn-str ds))
  (is (== "{:test 123}" result)))

(deftest add-to-existing-dict
  (def jdn "{:foo \"bar\"}")
  (def ds (c/jdn-str->jdn-arr jdn))
  (c/add-to ds [:baz] 42)
  (def result (c/jdn-arr->jdn-str ds))
  (is (string/find ":baz 42" result))
  (is (string/find ":foo \"bar\"" result)))

(deftest upd-in-simple
  (def jdn "{:foo \"bar\"}")
  (def ds (c/jdn-str->jdn-arr jdn))
  (c/upd-in ds [:foo] :to "baz")
  (def result (c/jdn-arr->jdn-str ds))
  (is (== "{:foo \"baz\"}" result)))

(deftest upd-in-number
  (def jdn "{:count 1}")
  (def ds (c/jdn-str->jdn-arr jdn))
  (c/upd-in ds [:count] :to 42)
  (def result (c/jdn-arr->jdn-str ds))
  (is (== "{:count 42}" result)))

(deftest rem-from-single-key
  (def jdn "{:foo \"bar\"}")
  (def ds (c/jdn-str->jdn-arr jdn))
  (c/rem-from ds [:foo])
  (def result (c/jdn-arr->jdn-str ds))
  (is (== "{}" result)))

(deftest rem-from-one-of-many
  (def jdn "{:foo \"bar\"\n :baz 42}")
  (def ds (c/jdn-str->jdn-arr jdn))
  (c/rem-from ds [:foo])
  (def result (c/jdn-arr->jdn-str ds))
  (is (== "{:baz 42}" result)))

(run-tests!)
