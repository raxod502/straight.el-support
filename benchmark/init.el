(setq package-enable-at-startup nil)
(setq custom-file (make-temp-file "garbage"))
(defalias #'display-startup-echo-area-message #'ignore)
(setq inhibit-startup-screen t)

(require 'cl-lib)
(require 'subr-x)

(unless load-file-name
  (error "You should load this file at Emacs initialization"))

(setq default-directory (file-name-directory
                         (file-truename load-file-name)))

(cl-letf (((symbol-function 'handle)
           (lambda () (setq command-line-args
                            (cdr command-line-args)))))
  (let ((packages
         (with-temp-buffer
           (insert-file-contents-literally "packages.el")
           (read (current-buffer))))
        (prev-arg nil)
        (package-count "25")
        (backend "straight")
        (named-args '(package-count backend))
        (install nil)
        (live nil))
    (dolist (arg command-line-args)
      (if (memq prev-arg named-args)
          (progn
            (set prev-arg arg)
            (setq prev-arg nil)
            (handle))
        (if (string-prefix-p "--" arg)
            (let ((sym (intern (substring arg 2))))
              (pcase sym
                ((guard (memq sym named-args))
                 (setq prev-arg sym)
                 (handle))
                (`install
                 (setq install t)
                 (handle))
                (`no-install
                 (setq install nil)
                 (handle))
                (`live
                 (setq live t)
                 (handle))
                (`no-live
                 (setq live nil)
                 (handle))
                (_ (error "Unknown argument `%s'" arg)))))))
    (setq package-count (string-to-number package-count))
    (setq backend (intern backend))

    (pcase backend
      (`straight
       (when (and install (file-exists-p "straight"))
         (delete-directory "straight" 'recursive))

       (benchmark
        1
        '(progn
           (setq straight-recipe-overrides
                 '((nil . ((straight :type git :host github
                                     :repo "raxod502/straight.el"
                                     :branch "develop"
                                     :files ("straight.el"))))))

           (when live
             (setq straight-check-for-modifications 'live))

           (let ((bootstrap-file (concat user-emacs-directory "straight/bootstrap.el"))
                 (bootstrap-version 2))
             (unless (file-exists-p bootstrap-file)
               (with-current-buffer
                   (url-retrieve-synchronously
                    "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
                    'silent 'inhibit-cookies)
                 (goto-char (point-max))
                 (eval-print-last-sexp)))
             (load bootstrap-file nil 'nomessage))

           (let ((idx 0))
             (cl-dolist (package packages)
               (straight-use-package (intern package))
               (cl-incf idx)
               (when (>= idx package-count)
                 (cl-return)))))))
      (`package
       (when (and install (file-exists-p "elpa"))
         (delete-directory "elpa" 'recursive))

       (benchmark
        1
        '(progn
           (setq package-archives
                 '(("melpa" . "https://melpa.org/packages/")
                   ("org" . "http://orgmode.org/elpa/")
                   ("gnu" . "http://elpa.gnu.org/packages/")))

           (package-initialize)

           (when install
             (package-refresh-contents)

             (let ((idx 0))
               (cl-dolist (package packages)
                 (package-install (intern package))
                 (cl-incf idx)
                 (when (>= idx package-count)
                   (cl-return))))))))
      (_ (error "Unknown backend: `%S'" backend)))))

(switch-to-buffer (messages-buffer))
