# Unidecode

ASCII transliterations of Unicode text. Julia port of [https://github.com/avian2/unidecode](https://github.com/avian2/unidecode).


## Installation

    pkg> add https://github.com/wswu/unidecode


## Usage

    julia> unidecode("你好")
    "Ni Hao "

Function signature:

    unidecode(str, errors="ignore", replace_str="?")