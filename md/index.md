# Változók

Ebben az anaygban változók fajtáiról, azoknak memóriában való tárolásáról és kezeléséről lesz szó.

## Alapok

**Minden**, ismétlem, **minden** - _számolható értékkel rendelkező_ - váltózó egy szám. Amikor egy `boolean`-ről vagy egy `char`-ról beszélünk, igazából csak számokat kezelünk. Például minden `boolean` - tehát igaz/hamis érték - felírható 0-ás vagy 1-es értékkel is.

Ennek demonstrálásához nem kell mélyre ásni, `python`-ban is látható:

```py
if 1:
    print("Hello world")
# kiírja, hogy "Hello world"

if 0:
    print("not hello")
# Nem történik semmi
```

## Egyszerű Típusok

Nyilvánvaló, hogy minden változó számként való kezelése nem a legátláthatóbb megoldás (_lásd: Hungarian Notation_), ezért a modern, programozási nyelvek különböző változó típusokat használnak.

### Integer - egész szám

#### Signed Integer:
Lehet negatív, ezt az első bit jelzi.

```txt
0xxx xxxx -> pozitív szám
1xxx xxxx -> Negatív szám
```

#### Unsigned Integer:
Nem lehet negatív, ezt az első bit jelzi.

Python demonstráció:

```py
x: int = int(32)
```

### Float - Lebegőpontos szám ~ racionális szám

IEEE 754 standard alapján implementált lebegőpontos számokkal reprezentáljuk a racionális számokat.

A lebegőpointos számok mindig **signed**, tehát előjeles változók:

```txt
                   IEEE 745
                   ˙˙˙˙˙˙˙˙
   x   xxxx xxxx   xxxxxxxxxxxxxxxxxxxxxxx
   |   ˙˙˙˙|˙˙˙˙   ˙˙˙˙˙˙˙˙˙˙˙|˙˙˙˙˙˙˙˙˙˙˙
 Előjel  Exponens         Mantissza
  (S)     (E)                (M)

                 f = 1.M × 2^E

```

Python demonstráció:

```py
x: float = float(32.332578)
```

### Boolean - Logikai érték / Igazságérték

A **boolean** typusú áltozók vagy igaz _(1)_ vagy hamis _(0)_ értéket hordoznak. Ilyen értéket létrehozhatunk a `true` és a `false` kulcsszavakkal, illetve **logikai operátorokkal**.

```py
x: bool = False # False / Hamis
y: bool = x == False # True / Igaz
z: bool = 5 > 4 # True / Igaz
```

### Char - Karakter

Egy darab karakter, kódolástól függ a mérete, de a gyakran használt ASCII (_American Standard Character for Information Interchange_) kódolásban `u8`-ként, tehát egy unsigned 8 bit hosszú integer értékként jelenik meg.

Több karakter összefűzése egy tömbbe vagy listába egy **string**-et,, azaz szöveget ad.

### String - Szöveg

Úgynevezett karakterlánc, melyet `char` változók tömbbe vagy listába helyezésével érünk el.

```py
x = ['H', 'e', 'l', 'l', 'o', ' ', 'w', 'o', 'r', 'l', 'd', '!']
```

Srting-ek kezelésére a magasabb szintű programnyelvekben (általában) külön típus is létezik.

```py
x: str = "Hello world!"
```

De low level, tehát alacsony szintű nyelvekben (C, Zig) ez a luxus nincs meg.

```rust
// Zig kód, de csak a rust-lang block-kal volt syntax highlighting
const x: const [3:0]u8 = "asd".*;
```

## Komplex Típusok

### Array - Tömb

Létrehozását követően nem bővíthető, egy változótípust tartalmazó lista. Ennek az adattípusnak nincs _alapértelmezett_ megfelelője `python`-ban.

```rust
const x: [?]i32 = [_]i32{1, 2, 3, 4};
```

### (Linked) List - Lista

Olyan adattípus, melynek minden eleme tartalmazza annak típusát, értékét és egy `pointer`-t a következő elemre. Ennek köszönhetően nem kell ugyan abból a típusból származnia minden elemnek. A lista utolsó eleme következő értékként mindig egy `null` értékre mutat.

Ezt az adattípust használjuk `python`-ban a mindennapokban.

```py
x: list = ["Hello", 0, True, False]
```

### Map / Dictionary

Kulcs-érték pár eltárárolására alkalmas adattípus. Legtöbb programozási nyelvben kötött az érték és a kulcs típusa is, de `python`-ban nem az.

```py
x: dict[str, int | float] = {
    "x": 0,
    "y": 1.124
}
```

### Function - Függvény

Olyan adattípus, mely nem önmagában nem reprezentál értéket, de meghívható; az ekkor megadott paraméterek és programállapot alapján készít új értéket, vagy ad vissza egy már meglevőt.

```py
def add(a: int, b: int) -> int:
    return a + b

z = add(1, 2)
# z == 3
```

### Null / Nullptr / None - Semmi

Olyan érték, vagy olyan értékre mutató érték, amely nem tartalmaz semmit, nem létezik.

```py
# Python
x = None
```

```c
// C
// #define NULL 0
int *x = NULL;
```

```c++
// C++
// "A null pointer constant is an integral constant expression (5.19) rvalue of integer type that evaluates to zero"
int *x = nullptr;
```

### Struct(ure) - *szerkezet*

Olyan adattípus, amely több alváltozót is tartalmaz. A programozók között véleményeltérések vannak, miszerint szabad-e az imént említett alváltozóknak függvényeknek lenniük (*Object Oriented Programming*), vagy sem (*Functional Programming*). 

*Ez hatalmas túlegyszerűsítés, és a problémák és nézeteltérések nem állnak meg itt, de itt is kimutatható és megfigyelhetó a szituáció*

Ez az adattípus főképp alacsonyabb szintű nyelvekben használt;

```rust
// Zig
const MyType = struct {
    x: i32 = 0,
    y: i32 = 0
};

const my_thing: MyType = MyType{ .x = 126, .y = 12 };
```

de `python`-ban is megvalósítható

```py
# Python
from dataclasses import dataclass

@dataclass
class MyType:
    x: int = 0
    y: int = 0

x: MyType = MyType(126, 12)
```