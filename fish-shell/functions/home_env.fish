# home_env.fish
# Contains home related setup

# Amazon EC2 instance static IP
set -x EUWEST '176.34.230.172'

# Home Server IP
set -x HS '172.30.115.111'

if test -L $HOME/.ec2
    set -x EC2_HOME $HOME/.ec2
    set -x PATH $PATH $EC2_HOME/bin
    set -x EC2_PRIVATE_KEY (ls $EC2_HOME/pk-*.pem)
    set -x EC2_CERT (ls $EC2_HOME/cert-*.pem)
    set -x EC2_URL https://ec2.eu-west-1.amazonaws.com
end

function home_env
end
