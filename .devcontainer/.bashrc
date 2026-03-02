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
prompt () {
  if $(git rev-parse --is-inside-work-tree 2>/dev/null); then
    git_root_dir=$(git rev-parse --show-toplevel)
    PS1="\[\e[0;34m\]$(basename ${git_root_dir})/\[\e[0;32m\]$(git rev-parse --show-prefix)"
  else
    PS1="${PWD}"
  fi
  PS1+="\[\e[33;1m\] $\[\e[m\] "
}

plan () {
  SECRETS="/mnt/devvol/persistent/$(git rev-parse --show-prefix)/secrets.tfvars"
  if [[ -e "${SECRETS}" ]]; then
    VARS="-var-file=${SECRETS}"
  fi
  tofu plan -out=plan ${VARS}
}

apply () {
  tofu apply plan
}

export PROMPT_COMMAND=prompt