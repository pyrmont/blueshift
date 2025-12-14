(import ../deps/churlish)
(import ../deps/medea)
(import ./base64)

(def api-base "https://api.github.com")

(defn- make-headers
  [token]
  {"Authorization" (string "Bearer " token)
   "Accept" "application/vnd.github+json"
   "X-GitHub-Api-Version" "2022-11-28"})

(defn- parse-response
  [response]
  (cond
    (string? response)
    (error response)
    (and (>= (response :status) 200)
         (< (response :status) 300))
    (if (empty? (response :body))
      {}
      (medea/decode (response :body)))
    # default
    (error (string "GitHub API error HTTP " (response :status) ": " (response :body)))))

(defn- get-file
  [token owner repo path]
  (def method (string "/repos/" owner "/" repo "/contents/" path))
  (def url (string api-base method))
  (def headers (make-headers token))
  (def response (churlish/http-get url :headers headers))
  (unless (= 404 (response :status))
    (parse-response response)))

(defn upload-file
  "Upload or update a file in a GitHub repository"
  [token owner repo path content]
  (def url (string api-base "/repos/" owner "/" repo "/contents/" path))
  (def existing (get-file token owner repo path))
  (def encoded (base64/encode content))
  (when existing
    (when (= encoded (string/replace-all "\n" "" (existing "content")))
      (break nil)))
  (def body-data (if existing
                   {:message "Update post"
                    :content encoded
                    :sha (existing "sha")}
                   {:message "Add post"
                    :content encoded}))
  (def body (medea/encode body-data))
  (def headers (make-headers token))
  (def response (churlish/http-put url :headers headers :body body))
  (parse-response response))
