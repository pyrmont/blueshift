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
                      :links [{:title "Article Title"
                               :uri "https://example.com/article"
                               :desc "An interesting article"
                               :thumb "https://example.com/thumb.jpg"}]}})
  (def expect
    ```
    ---
    date: 2024-01-15 12:30:45 +0000
    source: https://example.com/post/123
    link:
      url: https://example.com/article
      title: Article Title
      desc: An interesting article
      thumb: https://example.com/thumb.jpg
    ---

    Read more

    ```)
  (is (== expect (m/contents data))))

(deftest contents-with-link-facet
  (def data {:text "Check out https://example.com for more"
             :created "2024-01-15T12:30:45Z"
             :uri "https://example.com/post/123"
             :embeds {:images [] :links []}
             :facets [{"index" {"byteStart" 10 "byteEnd" 29}
                       "features" [{"$type" "app.bsky.richtext.facet#link"
                                    "uri" "https://example.com"}]}]})
  (def expect
    ```
    ---
    date: 2024-01-15 12:30:45 +0000
    source: https://example.com/post/123
    ---

    Check out [https://example.com](https://example.com) for more

    ```)
  (is (== expect (m/contents data))))

(deftest contents-with-mention-facet
  (def data {:text "Hey @alice how are you?"
             :created "2024-01-15T12:30:45Z"
             :uri "https://example.com/post/123"
             :embeds {:images [] :links []}
             :facets [{"index" {"byteStart" 4 "byteEnd" 10}
                       "features" [{"$type" "app.bsky.richtext.facet#mention"
                                    "did" "did:plc:alice123"}]}]})
  (def expect
    ```
    ---
    date: 2024-01-15 12:30:45 +0000
    source: https://example.com/post/123
    ---

    Hey [@alice](https://bsky.app/profile/did:plc:alice123) how are you?

    ```)
  (is (== expect (m/contents data))))

(deftest contents-with-hashtag-facet
  (def data {:text "Love this #bluesky experience"
             :created "2024-01-15T12:30:45Z"
             :uri "https://example.com/post/123"
             :embeds {:images [] :links []}
             :facets [{"index" {"byteStart" 10 "byteEnd" 18}
                       "features" [{"$type" "app.bsky.richtext.facet#tag"
                                    "tag" "bluesky"}]}]})
  (def expect
    ```
    ---
    date: 2024-01-15 12:30:45 +0000
    source: https://example.com/post/123
    ---

    Love this [#bluesky](https://bsky.app/hashtag/bluesky) experience

    ```)
  (is (== expect (m/contents data))))

(deftest contents-with-multiple-facets
  (def data {:text "Hey @alice check out https://example.com and use #bluesky"
             :created "2024-01-15T12:30:45Z"
             :uri "https://example.com/post/123"
             :embeds {:images [] :links []}
             :facets [{"index" {"byteStart" 4 "byteEnd" 10}
                       "features" [{"$type" "app.bsky.richtext.facet#mention"
                                    "did" "did:plc:alice123"}]}
                      {"index" {"byteStart" 21 "byteEnd" 40}
                       "features" [{"$type" "app.bsky.richtext.facet#link"
                                    "uri" "https://example.com"}]}
                      {"index" {"byteStart" 49 "byteEnd" 57}
                       "features" [{"$type" "app.bsky.richtext.facet#tag"
                                    "tag" "bluesky"}]}]})
  (def expect
    ```
    ---
    date: 2024-01-15 12:30:45 +0000
    source: https://example.com/post/123
    ---

    Hey [@alice](https://bsky.app/profile/did:plc:alice123) check out [https://example.com](https://example.com) and use [#bluesky](https://bsky.app/hashtag/bluesky)

    ```)
  (is (== expect (m/contents data))))

(deftest contents-with-no-facets
  (def data {:text "Just plain text"
             :created "2024-01-15T12:30:45Z"
             :uri "https://example.com/post/123"
             :embeds {:images [] :links []}
             :facets nil})
  (def expect
    ```
    ---
    date: 2024-01-15 12:30:45 +0000
    source: https://example.com/post/123
    ---

    Just plain text

    ```)
  (is (== expect (m/contents data))))

(deftest contents-with-empty-facets
  (def data {:text "Just plain text"
             :created "2024-01-15T12:30:45Z"
             :uri "https://example.com/post/123"
             :embeds {:images [] :links []}
             :facets []})
  (def expect
    ```
    ---
    date: 2024-01-15 12:30:45 +0000
    source: https://example.com/post/123
    ---

    Just plain text

    ```)
  (is (== expect (m/contents data))))

(deftest contents-with-facet-at-start
  (def data {:text "https://example.com is great"
             :created "2024-01-15T12:30:45Z"
             :uri "https://example.com/post/123"
             :embeds {:images [] :links []}
             :facets [{"index" {"byteStart" 0 "byteEnd" 19}
                       "features" [{"$type" "app.bsky.richtext.facet#link"
                                    "uri" "https://example.com"}]}]})
  (def expect
    ```
    ---
    date: 2024-01-15 12:30:45 +0000
    source: https://example.com/post/123
    ---

    [https://example.com](https://example.com) is great

    ```)
  (is (== expect (m/contents data))))

(deftest contents-with-facet-at-end
  (def data {:text "Check out https://example.com"
             :created "2024-01-15T12:30:45Z"
             :uri "https://example.com/post/123"
             :embeds {:images [] :links []}
             :facets [{"index" {"byteStart" 10 "byteEnd" 29}
                       "features" [{"$type" "app.bsky.richtext.facet#link"
                                    "uri" "https://example.com"}]}]})
  (def expect
    ```
    ---
    date: 2024-01-15 12:30:45 +0000
    source: https://example.com/post/123
    ---

    Check out [https://example.com](https://example.com)

    ```)
  (is (== expect (m/contents data))))

(deftest contents-with-repost
  (def data {:text "Great post!"
             :created "2024-01-15T12:30:45Z"
             :uri "https://example.com/post/123"
             :embeds {:images [] :links []}
             :repost? true})
  (def expect
    ```
    ---
    date: 2024-01-15 12:30:45 +0000
    source: https://example.com/post/123
    repost: true
    ---

    Great post!

    ```)
  (is (== expect (m/contents data))))

(deftest contents-with-quote-post
  (def data {:text "Adding my thoughts"
             :created "2024-01-15T12:30:45Z"
             :uri "https://example.com/post/123"
             :embeds {:images [] :links []}
             :quote-post? true
             :ref "at://did:plc:example/app.bsky.feed.post/abc123"})
  (def expect
    ```
    ---
    date: 2024-01-15 12:30:45 +0000
    source: https://example.com/post/123
    quote-post: true
    ref: at://did:plc:example/app.bsky.feed.post/abc123
    ---

    Adding my thoughts

    ```)
  (is (== expect (m/contents data))))

(deftest contents-with-quote-post-and-link
  (def data {:text "Check this out"
             :created "2024-01-15T12:30:45Z"
             :uri "https://example.com/post/123"
             :embeds {:images []
                      :links [{:title "Article"
                               :uri "https://example.com/article"
                               :desc "Description"
                               :thumb "https://example.com/thumb.jpg"}]}
             :quote-post? true
             :ref "at://did:plc:example/app.bsky.feed.post/xyz789"})
  (def expect
    ```
    ---
    date: 2024-01-15 12:30:45 +0000
    source: https://example.com/post/123
    quote-post: true
    ref: at://did:plc:example/app.bsky.feed.post/xyz789
    link:
      url: https://example.com/article
      title: Article
      desc: Description
      thumb: https://example.com/thumb.jpg
    ---

    Check this out

    ```)
  (is (== expect (m/contents data))))

(deftest contents-with-multiline-description
  (def data {:text "Interesting article"
             :created "2024-01-15T12:30:45Z"
             :uri "https://example.com/post/123"
             :embeds {:images []
                      :links [{:title "Article"
                               :uri "https://example.com/article"
                               :desc "First line\nSecond line\nThird line"
                               :thumb "https://example.com/thumb.jpg"}]}})
  (def expect
    ```
    ---
    date: 2024-01-15 12:30:45 +0000
    source: https://example.com/post/123
    link:
      url: https://example.com/article
      title: Article
      desc: |
        First line
        Second line
        Third line
      thumb: https://example.com/thumb.jpg
    ---

    Interesting article

    ```)
  (is (== expect (m/contents data))))

(run-tests!)
