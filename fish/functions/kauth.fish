# Work shortcut for switch k8s contexts
function kauth
    pscli kubectl auth && kubectx
end
