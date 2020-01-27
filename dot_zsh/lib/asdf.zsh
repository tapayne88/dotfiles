if type "asdf" > /dev/null; then
  source `dirname $(dirname $(which brew))`/opt/asdf/asdf.sh
  source `dirname $(dirname $(which brew))`/opt/asdf/etc/bash_completion.d/asdf.bash
fi
