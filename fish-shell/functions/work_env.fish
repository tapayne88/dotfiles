# WORKRC
# Contains work related setup

#export PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
    
alias grp 'grep -Isnr --exclude="tags" --exclude="*.txt" --exclude="*.sql" --exclude="*.min.js" --exclude-dir=".git" --exclude-dir="amd-build"'
alias grp_notest 'grep -Isnr --exclude="tags" --exclude="*.txt" --exclude="*.sql" --exclude="*.min.js" --exclude-dir=".git" --exclude-dir="amd-build" --exclude-dir="acceptance_tests" --exclude-dir="node" --exclude-dir="tests"'
    
alias cc "$HOME/Dropbox/Work/dev-machine/scripts/clearcache.sh"
alias cca "$HOME/Dropbox/Work/dev-machine/scripts/clearcache.sh and sudo service apache2 restart"
alias be "APPLICATION_ENV=testing ENVIRONMENT_OVERRIDE=$HOME/code/config/environment_override-test.ini $HOME/code/skybetdev/bin/behat"
alias ut "APPLICATION_ENV=testing ENVIRONMENT_OVERRIDE=$HOME/code/config/environment_override-test.ini $HOME/code/skybetdev/bin/phpunit-bundled --exclude-group oxilive --verbose"
alias applog "grc -c /home/payneth/.grc/pattern.conf tail -f /var/log/sky/application.log"
alias skyphing "ENVIRONMENT_OVERRIDE=$HOME/code/config/environment_override.ini phing"
    
#function get_redis_data () { redis-cli -h ${2:-"127.0.0.1"} -n 3 get $1 | php -r 'echo "\n\n" . unserialize(file_get_contents("php://stdin")) . "\n\n";'; };
#function zget_redis_data () { redis-cli -h ${2:-"127.0.0.1"} -n 3 get $1 | php -r 'echo "\n\n" . unserialize(gzuncompress(file_get_contents("php://stdin"))) . "\n\n";'; };
    
set -x devslave1 "172.16.2.162"

function work_env
end
