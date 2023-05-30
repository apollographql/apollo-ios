#!/bin/bash

touch $BASH_ENV
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
echo 'export NVM_DIR="$HOME/.nvm"' >> $BASH_ENV
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> $BASH_ENV
echo nvm install v12.22.10 >> $BASH_ENV
echo nvm use v18.16.0 >> $BASH_ENV
