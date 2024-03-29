;; compatible with emacs version 28 and above

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; starting our engines...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(package-initialize)

(unless (assoc-default "melpa" package-archives)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t))

(setq package-list '(use-package markdown-mode gcmh))

(unless package-archive-contents
  (package-refresh-contents))
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

(gcmh-mode 1) ;; reduce garbage collection interference

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; general config:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tool-bar-mode -1)                                      ;; no tool bar
(scroll-bar-mode -1)                                    ;; no scroll bar
(setq inhibit-startup-message t)                        ;; no splash screen
(setq use-short-answers t)                              ;; just type `y`, not `yes`
(setq mode-require-final-newline nil)                   ;; don't add a newline at the bottom of the file
(menu-bar-mode -1)                                      ;; no menu bar
(setq auto-save-file-name-transforms                                   ;;  save auto save data
      `((".*" ,(concat user-emacs-directory "auto-save-list/") t)))    ;;  in a separate directory
(setq backup-directory-alist                                           ;; save backup files
      `(("." . ,(concat user-emacs-directory "backups"))))             ;; in a separate directory
(blink-cursor-mode -1)                                  ;; don't blink my cursor
(global-auto-revert-mode +1)                            ;; auto revert files and buffers
(global-goto-address-mode +1)                           ;; make links/urls clickable
(add-hook 'dired-mode-hook #'auto-revert-mode)          ;; revert dired buffers, but not buffer list buffers
(delete-selection-mode +1)                              ;; delete selction when hitting backspace on region
(set-default 'truncate-lines t)                         ;; don't wrap my text
(add-hook 'prog-mode-hook #'hs-minor-mode)              ;; let me toggle shrink and expand code blocks 
(setq custom-file (locate-user-emacs-file "custom.el")) ;; separate custom.el file
(when (file-exists-p custom-file) (load custom-file))   ;; when it exists, load it
(setq initial-scratch-message "")                       ;; no message on scratch buffer
(setq auth-source-save-behavior nil)                    ;; don't prompt to save auth info in home dir
(setq-default indent-tabs-mode nil)                     ;; I prefer spaces instead of tabs
(setq-default tab-width 4)                              ;; I prefer a tab length of 4, not 8
(setq dired-listing-switches                            ;; I prefer to have dired
      "-aBhl  --group-directories-first")               ;; group my directories
(setq disabled-command-function nil)                    ;; enable all disabled commands

;; don't show `active processes exist` warning:
(defadvice save-buffers-kill-emacs (around no-query-kill-emacs activate)
  (cl-letf (((symbol-function #'process-list) (lambda ())))
    ad-do-it))

;; prevent active process when closing a shell like vterm or eshell:
(setq kill-buffer-query-functions (delq 'process-kill-buffer-query-function kill-buffer-query-functions))

;; show startup time on launch
(defun display-startup-echo-area-message ()
  (message "(emacs-init-time) -> %s" (emacs-init-time)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; use-package setup:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'use-package)

;; loads my favorite dark theme for emacs
(use-package modus-themes
  :ensure t
  :config
  (load-theme 'modus-vivendi :no-confim))

;; loads the best modeline for emacs
(use-package doom-modeline
  :ensure t
  :custom ((doom-modeline-height 16))
  :init (doom-modeline-mode 1))

;; for code snippets
(use-package yasnippet
  :ensure t)

;; for code snippets
(use-package yasnippet-snippets 
  :ensure t
  :config
  (add-hook 'prog-mode-hook #'yas-minor-mode))

(use-package expand-region
  :defer t
  :ensure t)

;; adds the best terminal emulator  for emacs
(use-package vterm
  :defer t
  :ensure t)

;; open a terminal in the working directory.
;; be sure to set your terminal by uncommenting 
;; the two lines below and replacing `st` with
;; your preferred terminal
(use-package terminal-here
  :defer t
  :ensure t
  ;; :init
  ;; (setq terminal-here-linux-terminal-command 'st)
  )

;; this prevents a long-standing bug with emacs and long lines
(use-package so-long
  :defer t
  :ensure t
  :init
  (global-so-long-mode +1))

;; intellisense/autocomplete 
(use-package company
  :defer t
  :ensure t
  :init
  (global-company-mode))

;; adds a function to restart emacs
(use-package restart-emacs
  :defer t
  :ensure t)

;; adds functions that allow window dynamic/relative resizing 
(use-package windsize
  :defer t
  :ensure t)

;; adds a lot of useful functions
(use-package crux
  :defer t
  :ensure t)

;; html editing toolkit
(use-package emmet-mode
  :ensure t
  :defer t
  :init
  (require 'emmet-mode)
  (add-hook 'html-mode-hook (lambda () (emmet-mode 1)))
  (add-hook 'sgml-mode-hook 'emmet-mode))

;; markdown support
(use-package markdown-mode
  :ensure t
  :defer t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))

;; an online thesaurus
(use-package mw-thesaurus
  :ensure t
  :defer t)

;; github markdown. allows markdown to html conversion
(use-package gh-md
  :ensure t
  :defer t)

;; completion frontend
(use-package ivy
  :defer t
  :ensure t
  :config
(add-to-list 'ivy-height-alist
             (cons 'counsel-find-file
                   (lambda (_caller)
                     (/ (frame-height) 2))))
(setq ivy-height-alist
      '((t
         lambda (_caller)
         (/ (frame-height) 2))))
  (setq ivy-initial-inputs-alist nil)
  (setq ivy-on-del-error-function #'ignore)
  :init
  (ivy-mode))

;; a part of the above package
(use-package counsel
  :defer t
  :ensure t
  :init
  (setq ivy-initial-inputs-alist nil)
  (when (commandp 'counsel-M-x)
    (global-set-key [remap execute-extended-command] #'counsel-M-x)))

;; for managing projects
(use-package projectile
  :ensure t
  :init
  (setq projectile-project-root-files '(".git/"))
  (setq projectile-ignored-projects '("~/"))
  (projectile-mode +1))

;; see function docstrings in M-x completion candidates
(use-package marginalia
  :defer t
  :ensure t
  :init
  (marginalia-mode))

;; emoji support
(use-package emojify
  :defer t
  :ensure t
  :init
  (setq emojify-display-style 'unicode)
  (setq emojify-emoji-styles '(unicode)))

;; cleaner directory editor settings
(use-package dired
  :ensure nil
  :config
  (add-hook 'dired-mode-hook
            (lambda ()
              (dired-hide-details-mode))))

;; switch window functions
(use-package switch-window
  :ensure t
  :defer t)

;; hex colors in editor
(use-package rainbow-mode
  :ensure t
  :defer t)

(use-package ivy-prescient
  :ensure t
  :defer t
  :config
  (ivy-prescient-mode))

;; make org look better with these bullet styles
(use-package org-bullets
  :ensure t
  :defer t
  :init
    (require 'org-bullets)
    (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))


;; best git wrapper
(use-package magit
  :ensure t
  :defer t)

;; updates packages every 30 days on emacs launch
(use-package auto-package-update
  :ensure t
  :config
  (setq auto-package-update-delete-old-versions t
        auto-package-update-interval 30)
  (auto-package-update-maybe))

(use-package smex
  :ensure t
  :config (smex-initialize))

(use-package git-gutter
  :ensure t
  :hook (prog-mode . git-gutter-mode)
  :config
  (setq git-gutter:update-interval 0.02))

(use-package git-gutter-fringe
  :ensure t
  :config
  (define-fringe-bitmap 'git-gutter-fr:added [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240] nil nil 'bottom))


;; highlight todos in documents
(use-package hl-todo
       :ensure t
       :custom-face
       (hl-todo ((t (:inherit hl-todo :italic t))))
       :hook ((prog-mode . hl-todo-mode)
              (yaml-mode . hl-todo-mode)))

;; saves the place of the cursor in each file
(use-package saveplace
  :init (save-place-mode))

;; similar to vscodes `code runner` extension. 
;; run code quickly without manually typing the shell command
(use-package quickrun
  :ensure t)

;; a better approach to key mappings
(use-package hydra
  :ensure t)

;; window configuration undo/redo
(use-package winner
  :ensure t
  :defer t)

(use-package helpful
  :ensure t
  :bind
  ([remap describe-key] . helpful-key)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-function] . helpful-callable))

(use-package volatile-highlights
  :ensure t
  :defer t
  :init
  (volatile-highlights-mode t))

;; one of the best tools to create a popup window, like a shell. requires setup
(use-package popper
  :ensure t)

