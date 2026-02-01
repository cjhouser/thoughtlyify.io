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

# Prompt dir is relative to git root
parse_git_repo() {
  if $(git rev-parse --is-inside-work-tree 2>/dev/null); then
    git_root_dir=$(git rev-parse --show-toplevel)
    echo -e "\e[0;34m$(basename ${git_root_dir})/\e[0;32m$(git rev-parse --show-prefix)"
  else
    echo "${PWD}"
  fi
}

# Example PS1 with the relative path in a subshell command
export PS1="\$(parse_git_repo)\e[33;1m $\e[m "