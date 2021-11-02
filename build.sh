#!/bin/bash

# update neologd
if [ ! -d mecab-ipadic-neologd ]; then
    git clone --filter=blob:none --no-checkout https://github.com/neologd/mecab-ipadic-neologd
    cd mecab-ipadic-neologd
    git config pull.rebase false
    git sparse-checkout init --cone
    git sparse-checkout set seed 
    git checkout
else
    cd mecab-ipadic-neologd
    git pull
fi
cd ..

if [ ! -d "source/raw" ]; then
    mkdir "source/raw"
fi
for file in mecab-ipadic-neologd/seed/*.xz; do
    xz -dc "$file" > "source/raw/$(basename -s .xz $file)"
done

# convert nlogd
python ./convert_neologd.py

# build
MECAB_DIC_COMPILER=$(mecab-config --libexecdir)/mecab-dict-index
$MECAB_DIC_COMPILER -f utf-8 -t utf-8 -d source/neologd -o dic/neologd/
