# Swift Docs

Prosty generator dokumentacji dla języka Swift, stworzony w ramach zajęć *Automaty i Gramatyki* na [PJATK](http://pja.edu.pl/).

## Zasada działania

* Lexer w pliku `src/swift_s.l` czyta tokeny języka Swift
* Parser w `src/swift_p.y` definiuje gramatykę, buduje drzewo i dokumentację w dwóch formatach
* `src/shell_formatter.c` zawiera metody wyświetlające dokumentację w linii poleceń
* `src/html_formatter.c` zawiera metody tworzące dokumentację HTML
* `src/tree.c` oraz `src/tree.h` zawierają struktury i metody do budowania drzewa dokumentowanej składni

## Jak używać?

Plik `Makefile` działa na macOS, ale powinien być kompatybilny z Linuxem po zmianie flagi `-ll` z wywołania `gcc` na flagę `-lfl`.

```
cd swift-docs
make
./swift example/TestFile.swift
```

Wygenerowana dokumentacja znajduje się w pliku `example/TestFile.swift.html`.
