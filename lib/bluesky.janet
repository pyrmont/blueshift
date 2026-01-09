(import ../deps/churlish)
(import ../deps/medea)
(import ./date)

(def- api-base "https://bsky.social/xrpc")

(defn- parse-response
  [response]
  (cond
    (string? response)
    (error response)
    (not= 200 (response :status))
    (error (string "Bluesky API error HTTP " (response :status) ": " (response :body)))
    # default
    (medea/decode (response :body))))

(defn- embed-data
  [embed]
  (def res @{})
  (when embed
    (case (embed "$type")
      "app.bsky.embed.images#view"
      (put res :images (seq [image :in (embed "images")] {:uri (image "fullsize")}))
      "app.bsky.embed.external#view"
      (do
        (def external (embed "external"))
        (put res :links [{:title (external "title")
                          :uri (external "uri")}]))))
  (table/to-struct res))

(defn- post-data
  [ds]
  (def post (get ds "post"))
  (def record (get post "record"))
  {:text (record "text")
   :uri (post "uri")
   :created (record "createdAt")
   :repost? (record "reason")
   :reply? (record "reply")
   :quote-post? (= "app.bsky.embed.record" (get-in record ["embed" "$type"]))
   :embeds (embed-data (post "embed"))})

(defn create-session
  "Authenticate with Bluesky and return session with DID and access JWT"
  [handle password]
  (def method "/com.atproto.server.createSession")
  (def url (string api-base method))
  (def body (medea/encode {:identifier handle :password password}))
  (def headers {"Content-Type" "application/json"})
  (def response (churlish/http-post url :headers headers :body body))
  (parse-response response))

(defn get-author-feed
  "Get posts from an author's feed"
  [session actor &opt limit cursor]
  (default limit 50)
  (def method "/app.bsky.feed.getAuthorFeed")
  (def params (string "?actor=" actor "&limit=" limit (when cursor (string "&cursor=" cursor))))
  (def url (string api-base method params))
  (def headers {"Authorization" (string "Bearer " (session "accessJwt"))})
  (def response (churlish/http-get url :headers headers))
  (parse-response response))

(defn fetch-posts
  "Fetch posts for an actor, potentially since a given date"
  [session actor &opt last-fetch limit]
  (def limit? (not (nil? limit)))
  (default limit 100)
  (def items @[])
  (var cursor nil)
  (var done false)
  (while (not done)
    (def result (get-author-feed session actor limit cursor))
    (def feed (result "feed"))
    (def cnt (length feed))
    (if last-fetch
      (each item feed
        (def created-at (get-in item ["post" "record" "createdAt"]))
        (def created-epoch (date/iso8601->epoch created-at))
        (if (and (< (length items) limit)
                 (> created-epoch last-fetch))
          (array/push items item)
          (set done true)))
      (do
        (def end (min (- limit (length items)) (length feed)))
        (array/concat items (array/slice feed 0 end))))
    (cond
      (and limit?
           (>= (length items) limit))
      (set done true)
      (and (not done) (result "cursor"))
      (set cursor (result "cursor"))
      # default
      (set done true)))
  (def posts @[])
  (each item items
    (array/push posts (post-data item)))
  posts)
