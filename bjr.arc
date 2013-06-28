; Blog tool example.  20 Jan 08, rev 21 May 09.
; Repurposed for personal analytics hacking.

; To run:
; arc> (load "lib/bjr.arc")
; arc> (bsv)
; go to http://localhost:8080/

(= postdir* "bjr/posts/"  maxid* 0  posts* (table))

(= blogtitle* "Brian's Blog")

(require "lib/re.arc")
(require "../feedback/graphs.arc")

(deftem post  id nil  title nil  text nil)

(def load-posts ()
  (each id (map int (dir postdir*))
    (= maxid*      (max maxid* id)
       (posts* id) (temload 'post (string postdir* id)))))

(def save-post (p) (temstore 'post p (string postdir* p!id)))

(def post (id) (posts* (errsafe:int id)))

(= green (color 10 200 75))

(def gen-css-url ()
  (prn "<link rel=\"stylesheet\" type=\"text/css\" href=\"data.css\">"))

(mac header nil 
  `(tag head
    (gen-css-url)
    (gentag meta name "viewport" content "width=device-width")
    (tag (script type "text/javscript" src "//use.typekit.net/gkp2xrv.js"))
    (tag (script type "text/javascript") (pr "try{Typekit.load();}catch(e){}"))))
    
(def color-stripe (c)
  (tag (table width 600 cellspacing 0 cellpadding 1)
    (tr (tdcolor c))))

(mac footer nil
  `(tag footer 
     (center
       (color-stripe green)
       (br 1)
       (w/bars (link "home" "/")
               (link "blog" "blog")
               (link "github" "https://github.com/brianru/")
               (link "twitter" "https://twitter.com/brianru")
               (link "linkedin"
                     "http://www.linkedin.com/pub/brian-j-rubinton/13/216/804")
               (link "contact" "mailto:brianrubinton@gmail.com")))))

(mac mainpage body
  `(tag html
    (header)
    (tag body
      (center
        (widtable 600
          (tag b
          (spacerow 10)
          ,@body
          (spacerow 30)))))
    (footer)))

; TODO
; defop data
; just display the graphs
; pass the body of this to mainpage once it works
; then get the formatting right
(mac datapage body
  `(tag html
     (header)
     (tag body
       (include-d3)
       (center 
         ;(widtable 600 ;integrate a custom table solution?
           ,@body));)
     (footer)))

(mac blogpage body
  `(tag html
    (header)
    (tag body
      (center
        (widtable 600
          (tag b (link blogtitle* "blog")) ; replace with navbar
          (br 3)
          ,@body
          (br 1)
          (w/bars (link "archive")
                  (link "new post" "newpost")))))
    (footer)))

(defop viewpost req (blogop post-page req))

(def blogop (f req)
  (aif (post (arg req "id"))
       (f (get-user req) it)
       (blogpage (pr "No such post."))))

(def permalink (p) (string "viewpost?id=" p!id))

(def post-page (user p) (blogpage (display-post user p)))

(def display-post (user p)
  (tag b (link p!title (permalink p)))
  (when user
    (sp)
    (link "[edit]" (string "editpost?id=" p!id)))
  (br2)
  (pr (re-replace "\r\n" p!text "<br>")))

(defopl newpost req
  (whitepage
    (aform [let u (get-user _)
             (post-page u (addpost u (arg _ "t") (arg _ "b")))]
      (tab (row "title" (input "t" "" 60))
           (row "text"  (textarea "b" 10 80))
           (row ""      (submit))))))

(def addpost (user title text)
  (let p (inst 'post 'id (++ maxid*) 'title title 'text text)
    (save-post p)
    (= (posts* p!id) p)))

(defopl editpost req (blogop edit-page req))

(def edit-page (user p)
  (whitepage
    (vars-form user
               `((string title ,p!title t t) (text text ,p!text t t))
               (fn (name val) (= (p name) val))
               (fn () (save-post p)
                      (post-page user p)))))

(defop archive req
  (blogpage
    (tag ul
      (each p (map post (rev (range 1 maxid*)))
        (tag li (link p!title (permalink p)))))))

(defop blog req
  (let user (get-user req)
    (blogpage
      (for i 0 4
        (awhen (posts* (- maxid* i))
          (display-post user it)
          (br 3))))))

(defop data req
  (datapage 
    (graph "\"spending-graph\"" "line" 300 100
           "https://dl.dropboxusercontent.com/u/641880/spending.csv")
    (graph "\"reading-graph\"" "bar" 300 100
           "https://dl.dropboxusercontent.com/u/641880/reading.csv")))

(= headshot-url "https://www.hackerschool.com/assets/people/brian_j_rubinton_150-f50597c1fa1d911d6d13719e9e396446.jpg")

(defop || req 
  (mainpage
    (gentag img src headshot-url border 0 vspace 3 hspace 2)
    (tr (tdc (prn "Hi! I'm Brian. Welcome to my website.")))
    (spacerow 10)
    (tr (tdc (prn "In this very corner of the internet, I am constructing")))
    (tr (tdc (prn "a personal analytics webservice with Arc.")))
    (spacerow 10)
    (tr (tdc (prn "Please return often for updates.")))))

(= testcss*
  "
  div#spending-graph { display: inline }
  div#reading-graph { display: inline }
  ")

(defop data.css req
  (pr testcss*))

(def bsv ()
  (ensure-dir postdir*)
  (load-posts)
  (asv))
