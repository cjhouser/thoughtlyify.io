# colorized pager
export PAGER=less

# ls colorized
export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'

# shortcuts
alias gitr="git rebase -i --autosquash main"
alias ns="kubectl config set-context --current --namespace"
alias tf=tofu

# kubectl shortcuts
alias k=kubectl
source <(kubectl completion bash)
complete -o default -F __start_kubectl k
