(add-hook 'before-save-hook 'delete-trailing-whitespace)
;; use setq-default so modes that want tabs can enable this
(setq-default indent-tabs-mode nil)

;; sh-mode customizations
(setq-default sh-basic-offset 2)
(setq-default sh-indentation 2)
