(add-hook 'before-save-hook 'delete-trailing-whitespace)
;; use setq-default so modes that want tabs can enable this
(setq-default indent-tabs-mode nil)
