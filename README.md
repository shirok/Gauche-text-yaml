# LibYAML bindings for Gauche

**This is still work in progress.  Not ready for general use.**

This package provides Gauche binding for [LibYAML](https://github.com/yaml/libyaml) v0.2.5.

NB: This module uses Gauche FFI feature which is not in the released
version of Gauche.  You need to install development HEAD of Gauche.

## Installation

```
./configure
make
make -s check
make install
```

## Usage

```
(use text.yaml)

(yaml-parse-file "input.yaml") ;=> S-expr
```

## High-level API

#### yaml-parse-file *file*

Read YAML document from *file*, parse it, and return the result
in S-expression.

A YAML sequence is mapped to a Scheme vector, and a YAML mapping
is mapped to a Scheme assoc-list.

This is implemented on top of mid-level API as follows.

```
(define (yaml-parse-file file)
  (let ([parser (make <yaml-parser>)])
    (unwind-protect
        (call-with-input-file file
          (^p (yaml-parser-set-input-port parser p)
              (yaml-parser-parse parser)))
      (yaml-fini parser))))
```

## Mid-level API

#### <yaml-parsre>

#### yaml-fini *parser*

#### yaml-parser-set-input-port *parser* *port*

#### yaml-parser-set-input-string *partser* *string*

#### yaml-parser-parse *parser*


## Low-level API
