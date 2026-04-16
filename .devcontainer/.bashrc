source /etc/bash_completion

# colorized pager
export PAGER=less

# ls colorized
export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'

# shortcuts
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

# terraform shortcuts
export TF_ROOT="/mnt/devvol/tf"
export TF_PLANS="${TF_ROOT}/plans"
export TF_SECRETS="${TF_ROOT}/secrets"
export TF_STATE="${TF_ROOT}/state"

plan () {
  ROOT_MODULE="$(git rev-parse --show-prefix | sed 's#/$##')"
  STATE="${TF_STATE}/${ROOT_MODULE}.tfstate"
  PLAN="${TF_PLANS}/${ROOT_MODULE}"
  SECRETS="${TF_SECRETS}/${ROOT_MODULE}.tfvars"
  if [[ -e "${SECRETS}" ]]; then
    VARS="-var-file=${SECRETS}"
  fi
  tofu plan -state=${STATE} -out=${PLAN} ${VARS}
}

apply () {
  ROOT_MODULE="$(git rev-parse --show-prefix | sed 's#/$##')"
  STATE="${TF_STATE}/${ROOT_MODULE}.tfstate"
  PLAN="${TF_PLANS}/${ROOT_MODULE}"
  tofu apply -state=${STATE} ${PLAN}
}

destroy () {
  ROOT_MODULE="$(git rev-parse --show-prefix | sed 's#/$##')"
  STATE="${TF_STATE}/${ROOT_MODULE}.tfstate"
  SECRETS="${TF_SECRETS}/${ROOT_MODULE}.tfvars"
  if [[ -e "${SECRETS}" ]]; then
    VARS="-var-file=${SECRETS}"
  fi
  tofu destroy -state=${STATE} ${VARS}
}

gitr () {
  git rebase -i --autosquash ${1:-main}
}

export PROMPT_COMMAND=prompt