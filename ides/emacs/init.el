;;; init.el --- Emacs config for artigo-revinfor (LaTeX + BibTeX)
;;
;; Usage:
;;   emacs -q -l /path/to/ides-configuration/emacs/init.el
;;
;; Or define a shell alias in your shell rc:
;;   alias emacs-revinfor='emacs -q -l ~/path/to/artigo-revinfor/ides-configuration/emacs/init.el'


;;; ---------------------------------------------------------------
;; 0a. Native compiler — silence false-positive warnings
;;     When packages are compiled to native code for the first time,
;;     the async compiler processes each file in isolation and cannot
;;     resolve cross-file forward references (e.g. modus-themes-theme,
;;     pdf-view-goto-page, ebib--update-buffers).  These warnings do
;;     not affect runtime behavior.  Setting this variable to 'silent
;;     keeps native compilation active while suppressing the noise.
;;; ---------------------------------------------------------------

(setq native-comp-async-report-warnings-errors 'silent)


;;; ---------------------------------------------------------------
;; 0b. Package bootstrap (straight.el + use-package)
;;     All packages land in a local .emacs-revinfor/ cache beside
;;     this file, keeping the system Emacs config untouched.
;;; ---------------------------------------------------------------

(defconst revinfor/config-dir
  (file-name-directory (or load-file-name buffer-file-name))
  "Directory that contains this init.el.")

(defconst revinfor/cache-dir
  (expand-file-name ".emacs-revinfor/" revinfor/config-dir)
  "Local package cache — keeps the system ~/.emacs.d clean.")

;; Redirect all Emacs ephemeral files into the local cache
(setq user-emacs-directory revinfor/cache-dir)
(setq package-user-dir (expand-file-name "elpa/" revinfor/cache-dir))

;; Bootstrap straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el"
                         revinfor/cache-dir))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)
(setq use-package-always-ensure t)


;;; ---------------------------------------------------------------
;; 1. Docker tool wrappers
;;    bin/ contains docker-latexmk and docker-chktex, which proxy
;;    the real binaries into the texlive container defined in the
;;    Makefile.  No local TeX installation is required.
;;; ---------------------------------------------------------------

(let ((bin-dir (expand-file-name "bin/" revinfor/config-dir)))
  (add-to-list 'exec-path bin-dir)
  (setenv "PATH" (concat bin-dir ":" (getenv "PATH"))))


;;; ---------------------------------------------------------------
;; 2. Core UI / UX
;;; ---------------------------------------------------------------

(setq inhibit-startup-screen t
      initial-scratch-message nil
      ring-bell-function 'ignore)

(menu-bar-mode   -1)
(tool-bar-mode   -1)
(scroll-bar-mode -1)
(column-number-mode 1)
(global-display-line-numbers-mode 1)
(show-paren-mode 1)

;; Sensible defaults
(setq-default indent-tabs-mode nil
              fill-column 80)
(setq sentence-end-double-space nil
      require-final-newline t)

;; Keep backup and auto-save files out of the project tree
(setq backup-directory-alist
      `(("." . ,(expand-file-name "backups/" revinfor/cache-dir)))
      auto-save-file-name-transforms
      `((".*" ,(expand-file-name "auto-save/" revinfor/cache-dir) t)))


;;; ---------------------------------------------------------------
;; 3. Fonts — Nerd Fonts installed on Fedora
;;    Tries a list of fonts commonly installed via ~/.local/share/fonts
;;    (manually unpacked Nerd Fonts) or `dnf install jetbrains-mono-fonts`
;;    etc., falling back to DejaVu Sans Mono, which ships with Fedora.
;;; ---------------------------------------------------------------

(defun revinfor/set-font ()
  "Set the default and fixed-pitch face to the first available font."
  (let ((font (seq-find (lambda (f) (member f (font-family-list)))
                         '("JetBrainsMono Nerd Font Mono"
                           "FiraCode Nerd Font Mono"
                           "Hack Nerd Font Mono"
                           "CaskaydiaCove Nerd Font Mono"
                           "DejaVu Sans Mono"))))
    (when font
      (set-face-attribute 'default nil :family font :height 110)
      (set-face-attribute 'fixed-pitch nil :family font :height 110))))

(add-hook 'after-init-hook #'revinfor/set-font)


;;; ---------------------------------------------------------------
;; 4. Theme
;;; ---------------------------------------------------------------

(use-package modus-themes
  :config
  (modus-themes-load-theme 'modus-operandi))   ; light theme, easy on the eyes
                                                ; swap for 'modus-vivendi for dark


;;; ---------------------------------------------------------------
;; 5. Completion framework (Vertico + Orderless + Marginalia)
;;; ---------------------------------------------------------------

(use-package vertico
  :init (vertico-mode 1))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :init (marginalia-mode 1))


;;; ---------------------------------------------------------------
;; 6. AUCTeX — LaTeX editing (all compilation via Docker)
;;; ---------------------------------------------------------------

;; :straight auctex installs the package; :package-name tex tells
;; use-package to (require 'tex), where TeX-command-list is defined.
;; Using (use-package auctex ...) would run :config before tex.el loads,
;; leaving TeX-command-list void.
(use-package tex
  :straight auctex
  :mode ("\\.tex\\'" . LaTeX-mode)
  :hook
  (LaTeX-mode . visual-line-mode)
  (LaTeX-mode . flyspell-mode)
  (LaTeX-mode . LaTeX-math-mode)
  (LaTeX-mode . turn-on-reftex)
  (LaTeX-mode . flymake-mode)     ; real-time syntax via docker-chktex
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-save-query nil)
  (TeX-source-correlate-mode t)
  (TeX-source-correlate-method 'synctex)
  (TeX-engine 'default)             ; 'default = pdflatex in modern AUCTeX
  (TeX-chktex-program "docker-chktex")
  :config
  (add-to-list 'TeX-command-list
               '("docker-latexmk"
                 "docker-latexmk -pdf -interaction=nonstopmode %t"
                 TeX-run-command nil t
                 :help "Run latexmk inside the texlive Docker container"))
  (setq TeX-command-default "docker-latexmk")
  (setq-default TeX-master nil))   ; prompts once, then caches in .dir-locals


;;; ---------------------------------------------------------------
;; 7. PDF viewer — pdf-tools (in-Emacs viewer with SyncTeX support)
;;; ---------------------------------------------------------------

(use-package pdf-tools
  :magic ("%PDF" . pdf-view-mode)
  :config
  (pdf-tools-install :no-query)
  (setq pdf-view-display-size 'fit-width)
  ;; Wire SyncTeX: C-c C-v in LaTeX-mode jumps to the matching PDF spot
  (setq TeX-view-program-selection '((output-pdf "PDF Tools")))
  (setq TeX-view-program-list
        '(("PDF Tools" TeX-pdf-tools-sync-view)))
  (add-hook 'TeX-after-compilation-finished-functions
            #'TeX-revert-document-buffer))


;;; ---------------------------------------------------------------
;; 8. BibTeX / ebib — bibliography manager
;;    ebib is the closest Linux equivalent to BibDesk.
;;; ---------------------------------------------------------------

(use-package ebib
  :bind
  ("C-c e" . ebib)               ; open ebib from anywhere
  :custom
  ;; Point ebib at the project's bibliography files
  (ebib-bib-search-dirs
   (list (expand-file-name "../../" revinfor/config-dir)           ; repo root
         (expand-file-name "../../common-shared/bib/" revinfor/config-dir)
         (expand-file-name "../../artigo_modelo_revista_infor/" revinfor/config-dir)
         (expand-file-name "../../artigo_curso_defectologia_vigostky/" revinfor/config-dir)))
  (ebib-preload-bib-files
   '("artigo_modelo_revista_infor/references.bib"
     "artigo_curso_defectologia_vigostky/references.bib"
     "common-shared/bib/abntex2-modelo-references.bib"))
  (ebib-index-default-sort '("Author" . ascend))
  (ebib-use-timestamp t)
  :config
  ;; Insert ABNT-style citation with \citeonline{key} via C-c C-e c
  (defun revinfor/ebib-insert-citeonline ()
    "Insert \\citeonline{KEY} at point using the current ebib entry."
    (interactive)
    (ebib-push-bibtex-key)
    (save-excursion
      (search-backward "{")
      (insert "\\citeonline"))))


;;; ---------------------------------------------------------------
;; 9. RefTeX — cross-references, citations, labels
;;    Works alongside AUCTeX; aware of abntex2 cite commands.
;;; ---------------------------------------------------------------

(use-package reftex
  :straight nil                  ; built into Emacs
  :after tex
  :custom
  (reftex-plug-into-AUCTeX t)
  ;; Teach RefTeX about the ABNT citation commands used in this project
  (reftex-cite-format
   '((?\C-m . "\\cite{%l}")
     (?o    . "\\citeonline{%l}")
     (?a    . "\\citeauthor{%l}")
     (?y    . "\\citeyear{%l}")
     (?f    . "\\citefullauthor{%l}")))
  (reftex-bibliography-commands '("bibliography" "nobibliography" "addbibresource")))


;;; ---------------------------------------------------------------
;; 10. Flyspell — spell checking (Brazilian Portuguese)
;;    hunspell is the only tool that still needs a local install;
;;    it checks natural language, not LaTeX, so Docker is not useful here.
;;    Install: sudo dnf install hunspell hunspell-pt-BR
;;; ---------------------------------------------------------------

(use-package flyspell
  :straight nil
  :hook (LaTeX-mode . flyspell-mode)
  :custom
  (ispell-program-name "hunspell")
  (ispell-dictionary "pt_BR")   ; hunspell-pt-BR on Fedora registers as "pt_BR"
                                 ; switch with M-x ispell-change-dictionary
  :config
  ;; Flyspell only marks a word when point moves onto it (its checking is
  ;; driven by post-command-hook, not a scan of the whole buffer) — text
  ;; already on disk stays unmarked until you happen to visit each word.
  ;; Force a full check right when the mode turns on so every misspelling
  ;; is already visible while just scrolling, without touching point.
  (add-hook 'flyspell-mode-hook
            (lambda ()
              (when flyspell-mode
                (flyspell-buffer)))))


;;; ---------------------------------------------------------------
;; 11. Org-mode tweaks (for README.org / PROJECT_ANALYSIS.org)
;;; ---------------------------------------------------------------

(use-package org
  :straight nil
  :mode ("\\.org\\'" . org-mode)
  :custom
  (org-startup-folded 'content)
  (org-hide-leading-stars t)
  (org-src-fontify-natively t)
  (org-src-tab-acts-natively t))


;;; ---------------------------------------------------------------
;; 12. Project navigation — project.el pointing at the repo root
;;; ---------------------------------------------------------------

(use-package project
  :straight nil
  :config
  ;; Register the repo root directly as a Git project.
  ;; project-remember-projects-under searches *inside* a directory for
  ;; sub-projects and won't register the directory itself.
  (let ((root (expand-file-name "../../" revinfor/config-dir)))
    (when (file-directory-p (expand-file-name ".git" root))
      (project-remember-project `(vc Git ,root)))))


;;; ---------------------------------------------------------------
;; 13. Magit — Git porcelain
;;; ---------------------------------------------------------------

(use-package magit
  :bind
  ("C-x g" . magit-status))


;;; ---------------------------------------------------------------
;; 14. Treemacs — file/directory sidebar
;;; ---------------------------------------------------------------

(use-package treemacs
  :bind
  (("<f8>"    . treemacs-select-window)  ; C-c C-o was requested, but AUCTeX
                                          ; (TeX-fold prefix) and org-mode
                                          ; (org-open-at-point) already claim
                                          ; it in .tex/.org buffers, so it
                                          ; would silently do nothing there.
   ("M-0"     . treemacs-select-window)
   ("C-x t t" . treemacs)
   ("C-x t d" . treemacs-select-directory)
   ("C-x t B" . treemacs-bookmark)
   ("C-x t C-t" . treemacs-find-file)
   ("C-x t M-t" . treemacs-find-tag))
  :custom
  (treemacs-width 35)
  (treemacs-is-never-other-window t)
  (treemacs-sorting 'alphabetic-case-insensitive-asc)
  :config
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode 'always)
  (treemacs-git-mode 'deferred))

(use-package treemacs-nerd-icons
  :after treemacs
  :config
  (treemacs-load-theme "nerd-icons"))

;; Open treemacs automatically at startup, pointed at the repo root.
;; `treemacs-add-and-display-current-project-exclusively' resolves the
;; project via project.el (registered in section 12) without ever
;; prompting — unlike plain `treemacs', which asks for a root path
;; interactively the first time the workspace is empty.
;; default-directory at launch is the invoking shell's cwd, not the repo,
;; so it's bound locally just for this call.
(add-hook 'emacs-startup-hook
          (lambda ()
            (let ((default-directory (expand-file-name "../../" revinfor/config-dir)))
              (treemacs-add-and-display-current-project-exclusively))))


;;; ---------------------------------------------------------------
;; 15. Useful keybindings summary
;;
;;  LaTeX editing (LaTeX-mode):
;;    C-c C-c       — compile via docker-latexmk (inside texlive container)
;;    C-c C-v       — view PDF (pdf-tools, SyncTeX)
;;    C-c C-e       — insert environment
;;    C-c C-s       — insert section
;;    C-c [         — insert \cite via RefTeX   (also C-c C-e o for \citeonline)
;;    C-c (         — insert \label via RefTeX
;;    C-c )         — insert \ref   via RefTeX
;;    C-c e         — open ebib bibliography manager
;;    (flymake)     — docker-chktex runs automatically; errors shown inline
;;
;;  PDF viewer (pdf-view-mode):
;;    C-c C-g       — SyncTeX backward search (jump to .tex source)
;;    n / p         — next / previous page
;;    + / -         — zoom in / out
;;    s w           — fit to window width
;;
;;  Treemacs (file/directory sidebar, opens automatically at startup):
;;    <f8> / M-0    — jump to the treemacs window
;;    C-x t t       — open/close treemacs
;;    C-x t d       — open treemacs for a chosen directory
;;    C-x t B       — treemacs bookmark
;;    C-x t C-t     — find current file in treemacs
;;
;;  Magit (Git porcelain):
;;    C-x g         — open magit-status
;;; ---------------------------------------------------------------

(provide 'init)
;;; init.el ends here
