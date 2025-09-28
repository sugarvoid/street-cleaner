#!/bin/bash
zip -9 -r street-cleaner.love . \
    --exclude '*.git*' \
    '*.vscode*' \
    '*.gif'\
    '*.mp4'\
    '*.sh' \
    'todo.md' \
    'sublime-build.txt' \
    'asset/image/down_mail.png' \
    'asset/image/down_mail.svg'
