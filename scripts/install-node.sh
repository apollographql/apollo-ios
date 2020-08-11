#!/bin/bash

touch $BASH_ENV
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
echo 'export NVM_DIR="$HOME/.nvm"' >> $BASH_ENV
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> $BASH_ENV
echo nvm install 12 >> $BASH_ENV
echo nvm alias default 12 >> $BASH_ENV
echo nvm use default >> $BASH_ENV