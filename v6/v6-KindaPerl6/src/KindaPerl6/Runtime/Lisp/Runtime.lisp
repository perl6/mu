(with-compilation-unit ()
  (dolist (file
            `("defpackage"
              "util" "var" "user"
              "Interpreter"
              "error"
              "compat/stub"
              ,(format nil "compat/~A"
                       #+:sbcl "sbcl"
                       #-:sbcl "other")
              "MOP"
              "Object" "Cell" "Signature"
              "Value" "Container"       ; Base classes
              "Undef"                   ; Undef
              "Bit" "Num" "Int" "Str" "Code" ; Values
              "Hash" "Array"            ; Containers
              "Package" "Pad"
              "foreign"                 ; Utilities
              "display" "coerce"        ; Utilities
              "GLOBAL"                  ; Functions
              ))
    (load (format nil "src/KindaPerl6/Runtime/Lisp/~A.lisp" file))))
