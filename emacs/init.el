(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["black" "#d55e00" "#009e73" "#f8ec59" "#0072b2" "#cc79a7" "#56b4e9" "white"])
 '(custom-enabled-themes '(manoj-dark))
 '(package-selected-packages
   '(ace-window browse-kill-ring atomic-chrome zygospore abyss-theme electric-pair auto-complete-config auto-complete markdown-mode markdown-mode+ markdown-preview-mode magit org-bullets which-key use-package try)))

;;;; user set stuff
(setq inhibit-startup-message t)
(column-number-mode 1)
(electric-pair-mode 1)
(put 'narrow-to-region 'disabled nil)
(setq create-lockfiles nil)
;; indenting
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq indent-line-function 'insert-tab)

;;;; better unique naming of file buffers with the same name
(require 'uniquify)
(setq uniquify-buffer-name-style 'reverse)
(setq uniquify-separator "|")
(setq uniquify-after-kill-buffer-p t)
(setq uniquify-ignore-buffers-re "^\\*")

;;;; remember recently opened files
(recentf-mode t)
(global-set-key (kbd "<f7>") 'recentf-open-files)
(save-place-local-mode)
(setq-default fill-column 80)

;;;; save buffers
(desktop-save-mode)

;;;; line number mode
(global-display-line-numbers-mode)
(set-face-foreground 'line-number "firebrick")
(set-face-foreground 'line-number-current-line "DarkOrange2")

(defun display-line-numbers-equalize ()
  "Equalize the width.  For more information, see: https://emacs.stackexchange.com/a/55166/8887."
  (setq display-line-numbers-width
        (length (number-to-string (line-number-at-pos (point-max))))))
(add-hook 'find-file-hook 'display-line-numbers-equalize)

;;;; straight.el
;;
;; also see .emacs.d/early-init.el for preconfig
(setq straight-use-package-by-default t)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; update melpa
(straight-pull-package "melpa")

;;;; use-package

;; make sure use-package is installed
(straight-use-package 'use-package)

;; installed packages
(use-package browse-kill-ring
  :config
  (global-set-key (kbd "C-c y") 'browse-kill-ring))


(use-package magit)

(use-package auto-complete
  :config
  (ac-config-default))

(use-package markdown-mode
  :commands
  (markdown-mode gfm-mode)
  :mode
  (("README\\.md\\'" . gfm-mode)
   ("\\.md\\'" . markdown-mode)
   ("\\.markdown\\'" . markdown-mode))
  :init
  (setq markdown-command "multimarkdown"))

(use-package helm
  :config
  (global-set-key (kbd "M-x") #'helm-M-x)
  (global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
  (global-set-key (kbd "C-x C-f") #'helm-find-files)
  (helm-mode 1))

(use-package web-server)

;; window / buffer management
(use-package ace-window
  :config
  (global-unset-key (kbd "C-x o"))
  (global-set-key (kbd "C-x o") 'ace-window)
  (setq aw-keys '(?j ?k ?l ?\;))
  (setq aw-background nil))

(use-package zygospore
  :config
  (global-set-key (kbd "C-x 1") 'zygospore-toggle-delete-other-windows))

(use-package buffer-move
  :init
  (global-unset-key (kbd "C-c j"))
  (global-unset-key (kbd "C-c k"))
  (global-unset-key (kbd "C-c l"))
  (global-unset-key (kbd "C-c ;"))
  :config
  (global-set-key (kbd "C-c j") 'buf-move-left)
  (global-set-key (kbd "C-c k") 'buf-move-up)
  (global-set-key (kbd "C-c l") 'buf-move-down)
  (global-set-key (kbd "C-c ;") 'buf-move-right)
  (setq buffer-move-stay-after-swap t))

(defun toggle-window-split ()
  "Toggle between horizontal / vertical window split for two windows.
This needs to be added to a repo and installed via straight / use-package."
  (interactive)
  (if (= (count-windows) 2)
      (let* ((this-win-buffer (window-buffer))
             (next-win-buffer (window-buffer (next-window)))
             (this-win-edges (window-edges (selected-window)))
             (next-win-edges (window-edges (next-window)))
             (this-win-2nd (not (and (<= (car this-win-edges)
					                               (car next-win-edges))
				                             (<= (cadr this-win-edges)
					                               (cadr next-win-edges)))))
             (splitter
              (if (= (car this-win-edges)
		                 (car (window-edges (next-window))))
		              'split-window-horizontally
		            'split-window-vertically)))
	      (delete-other-windows)
	      (let ((first-win (selected-window)))
	        (funcall splitter)
	        (if this-win-2nd (other-window 1))
	        (set-window-buffer (selected-window) this-win-buffer)
	        (set-window-buffer (next-window) next-win-buffer)
	        (select-window first-win)
	        (if this-win-2nd (other-window 1))))))

(global-set-key (kbd "C-c i") 'toggle-window-split)


;; syntax checking, linting, highlighting
(use-package emmet-mode
  :config
  (add-hook 'html-mode-hook 'emmet-mode)
  (add-hook 'sgml-mode-hook 'emmet-mode)
  (add-hook 'css-mode-hook 'emmet-mode)
  (add-hook 'emmet-mode-hook
	          (lambda () (setq emmet-indent-after-insert nil)))
  (add-hook 'emmet-mode-hook
	          (lambda () (setq emmet-indentation 2)))
  (setq emmet-expand-jsx-className? t)
  (setq emmet-self-closing-tag-style " /")
  (setq emmet-move-cursor-between-quotes t)
  (global-set-key (kbd "C-c '") 'emmet-expand-line))

(use-package highlight-indent-guides
  :config
  (add-hook 'prog-mode-hook 'highlight-indent-guides-mode))

(use-package yasnippet
  :config
  (yas-global-mode 1))

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c [")
  :hook
  ((prog-mode-hook . lsp)
   (lsp-mode . lsp-enable-which-key-integration))
  :commands
  lsp)

(use-package lsp-ui
  :commands lsp-ui-mode)

(use-package helm-lsp
  :commands helm-lsp-workspace-symbol)

(use-package which-key
  :config
  (which-key-mode))

(use-package flycheck
  :init
  (global-flycheck-mode)
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode))

(use-package company
  :config
  (add-hook 'after-init-hook 'global-company-mode))

(use-package lsp-treemacs
  :commands
  (lsp-treemacs-errors-list)
  :config
  (lsp-treemacs-sync-mode 1))

(use-package helm-lsp
  :config
  (define-key lsp-mode-map [remap xref-find-apropos] #'helm-lsp-workspace-symbol))

(use-package treemacs
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay      0.5
          treemacs-directory-name-transformer    #'identity
          treemacs-display-in-side-window        t
          treemacs-eldoc-display                 t
          treemacs-file-event-delay              5000
          treemacs-file-extension-regex          treemacs-last-period-regex-value
          treemacs-file-follow-delay             0.2
          treemacs-file-name-transformer         #'identity
          treemacs-follow-after-init             t
          treemacs-expand-after-init             t
          treemacs-git-command-pipe              ""
          treemacs-goto-tag-strategy             'refetch-index
          treemacs-indentation                   2
          treemacs-indentation-string            " "
          treemacs-is-never-other-window         nil
          treemacs-max-git-entries               5000
          treemacs-missing-project-action        'ask
          treemacs-move-forward-on-expand        nil
          treemacs-no-png-images                 nil
          treemacs-no-delete-other-windows       t
          treemacs-project-follow-cleanup        nil
          treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                      'left
          p         treemacs-read-string-input             'from-child-frame
          treemacs-recenter-distance             0.1
          treemacs-recenter-after-file-follow    nil
          treemacs-recenter-after-tag-follow     nil
          treemacs-recenter-after-project-jump   'always
          treemacs-recenter-after-project-expand 'on-distance
          treemacs-litter-directories            '("/node_modules" "/.venv" "/.cask")
          treemacs-show-cursor                   nil
          treemacs-show-hidden-files             t
          treemacs-silent-filewatch              nil
          treemacs-silent-refresh                nil
          treemacs-sorting                       'alphabetic-asc
          treemacs-space-between-root-nodes      t
          treemacs-tag-follow-cleanup            t
          treemacs-tag-follow-delay              1.5
          treemacs-user-mode-line-format         nil
          treemacs-user-header-line-format       nil
          p          treemacs-width                         35
          treemacs-width-is-initially-locked     t
          treemacs-workspace-switch-cleanup      nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-icons-dired
  :after (treemacs dired)
  
  :config (treemacs-icons-dired-mode))

(use-package treemacs-magit
  :after (treemacs magit)
  )

(use-package perspective
  :bind
  ("C-x C-b" . persp-list-buffers)
  :hook
  ('kill-emacs-hook . #'persp-state-save)
  :config
  (persp-mode))

(use-package treemacs-perspective
  :after (treemacs perspective)
  :config (treemacs-set-scope-type 'Perspectives))

(use-package vterm
  :config
  (define-key vterm-mode-map (kbd "<C-backspace>")
    (lambda () (interactive) (vterm-send-key (kbd "C-w"))))
  (defun vterm-counsel-yank-pop-action (orig-fun &rest args)
    "https://github.com/zetaomegagon/emacs-libvterm#frequently-asked-questions-and-problems."
    (if (equal major-mode 'vterm-mode)
	      (let ((inhibit-read-only t)
              (yank-undo-function (lambda (_start _end) (vterm-undo))))
          (cl-letf (((symbol-function 'insert-for-yank)
		                 (lambda (str) (vterm-send-string str t))))
            (apply orig-fun args)))
      (apply orig-fun args)))
  (advice-add 'counsel-yank-pop-action :around #'vterm-counsel-yank-pop-action))

(use-package multi-vterm
  :config
  (global-set-key (kbd "C-c t") #'multi-vterm))

;; disable the menu-bar in cli and toolbar in gui.
;; disable scrollbar in both
(menu-bar-mode -1)
(tool-bar-mode -1)
(toggle-scroll-bar -1)

;; browse various package repos using "M-x package-list"
(require 'package)
(add-to-list 'package-archives
	           '("melpa" . "https://melpa.org/packages/")
	           '("melpa-stable" . "https://stable.melpa.org/packages/"))
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

(provide 'init)
;;; init.el ends here
