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

(straight-use-package 'el-patch)
(require 'el-patch)

(straight-use-package 'bind-key)
(require 'bind-key)

(straight-use-package 'ivy)
(require 'ivy)
(ivy-mode +1)

(straight-use-package 'counsel)
(bind-keys
 ("C-h   f" . counsel-describe-function)
 ("C-h   l" . counsel-load-library)
 ("C-h   v" . counsel-describe-variable)
 ("C-h C-l" . counsel-find-library)
 ("C-x C-f" . counsel-find-file)
 ("M-x    " . counsel-M-x))

(straight-use-package 'visual-regexp)
(bind-key "M-%" #'vr/query-replace)

(straight-use-package 'magit)
(bind-key "C-x g" #'magit-status)

(straight-use-package 'git-commit)
(require 'git-commit)
(global-git-commit-mode +1)

(straight-use-package 'org)
(bind-key "C-c a" #'org-agenda)
(with-eval-after-load 'org
  (add-hook 'org-mode-hook #'org-indent-mode))

(straight-use-package 'auctex)
(el-patch-feature tex)
(with-eval-after-load 'tex
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (el-patch-defun TeX-update-style (&optional force)
    "Run style specific hooks for the current document.

Only do this if it has not been done before, or if optional argument
FORCE is not nil."
    (unless (or (and (boundp 'TeX-auto-update)
                     (eq TeX-auto-update 'BibTeX)) ; Not a real TeX buffer
                (and (not force)
                     TeX-style-hook-applied-p))
      (setq TeX-style-hook-applied-p t)
      (el-patch-remove
        (message "Applying style hooks..."))
      (TeX-run-style-hooks (TeX-strip-extension nil nil t))
      ;; Run parent style hooks if it has a single parent that isn't itself.
      (if (or (not (memq TeX-master '(nil t)))
              (and (buffer-file-name)
                   (string-match TeX-one-master
                                 (file-name-nondirectory (buffer-file-name)))))
          (TeX-run-style-hooks (TeX-master-file)))
      (if (and TeX-parse-self
               (null (cdr-safe (assoc (TeX-strip-extension nil nil t)
                                      TeX-style-hook-list))))
          (TeX-auto-apply))
      (run-hooks 'TeX-update-style-hook)
      (el-patch-remove
        (message "Applying style hooks... done")))))

(straight-use-package 'yaml-mode)
