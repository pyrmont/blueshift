(use ../deps/testament)

(import ../lib/markdown :as m)

(deftest filename-simple
  (def data {:text "Hello world this is a test"
             :created "2024-01-15T12:30:45Z"})
  (is (== "2024-01-15-hello-world.md" (m/filename data))))

(deftest filename-with-long-word
  (def data {:text "Supercalifragilisticexpialidocious is amazing"
             :created "2024-01-15T12:30:45Z"})
  (is (== "2024-01-15-supercalifragilistic.md" (m/filename data))))

(deftest filename-special-chars-removed
  (def data {:text "Hello! @world #test $money"
             :created "2024-01-15T12:30:45Z"})
  (is (== "2024-01-15-hello-world.md" (m/filename data))))

(deftest filename-max-length
  (def data {:text "verylongwordthatexceedstwentycharacters"
             :created "2024-01-15T12:30:45Z"})
  (is (== "2024-01-15-verylongwordthatexce.md" (m/filename data))))

(deftest contents-basic-structure
  (def data {:text "Hello world"
             :created "2024-01-15T12:30:45Z"
             :uri "https://example.com/post/123"
             :embeds {:images [] :links []}})
  (def expect
    ```
    ---
    date: 2024-01-15 12:30:45 +0000
    source: https://example.com/post/123
    ---

    Hello world

    ```)
  (is (== expect (m/contents data))))

(deftest contents-with-images
  (def data {:text "Check this out"
             :created "2024-01-15T12:30:45Z"
             :uri "https://example.com/post/123"
             :embeds {:images [{:title "Photo" :uri "https://example.com/img.jpg"}]
                      :links []}})
  (def expect
    ```
    ---
    date: 2024-01-15 12:30:45 +0000
    source: https://example.com/post/123
    ---

    Check this out

    ![Photo](https://example.com/img.jpg)

    ```)
  (is (== expect (m/contents data))))

(deftest contents-with-links
  (def data {:text "Read more"
             :created "2024-01-15T12:30:45Z"
             :uri "https://example.com/post/123"
             :embeds {:images []
                      :links [{:title "Article" :uri "https://example.com/article"}]}})
  (def expect
    ```
    ---
    date: 2024-01-15 12:30:45 +0000
    source: https://example.com/post/123
    ---

    Read more

    [Article](https://example.com/article)

    ```)
  (is (== expect (m/contents data))))

(run-tests!)
