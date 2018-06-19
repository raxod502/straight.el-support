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

(straight-use-package 'use-package)
(require 'use-package)
(setq use-package-always-defer t)
(straight-use-package-enable-by-default-mode +1)

(use-package el-patch
  :demand t)

(use-package bind-key
  :demand t)

(use-package ivy
  :demand t
  :config

  (ivy-mode +1))

(use-package counsel
  :bind (("C-h   f" . counsel-describe-function)
         ("C-h   l" . counsel-load-library)
         ("C-h   v" . counsel-describe-variable)
         ("C-h C-l" . counsel-find-library)
         ("C-x C-f" . counsel-find-file)
         ("M-x    " . counsel-M-x)))

(use-package visual-regexp
  :bind (("M-%" . vr/query-replace)))

(use-package magit
  :bind (("C-x g" . magit-status)))

(use-package git-commit
  :demand t
  :config

  (global-git-commit-mode +1))

(use-package org
  :bind (("C-c a" . org-agenda))
  :config

  (add-hook 'org-mode-hook #'org-indent-mode))

(use-package tex
  :straight auctex
  :init

  (el-patch-feature tex)

  :config

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

(use-package yaml-mode)
