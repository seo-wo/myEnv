export CLICOLOR=1
export LSCOLORS=DxFxCxGxBxegedabagaced

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  # NOTE: This segment separator character is correct.  In 2012, Powerline changed
  # the code points they use for their special characters. This is the new code point.
  # If this is not working for you, you probably have an old version of the
  # Powerline-patched fonts installed. Download and install the new version.
  # Do not submit PRs to change this unless you have reviewed the Powerline code point
  # history and have new information.
  # This is defined using a Unicode escape sequence so it is unambiguously readable, regardless of
  # what font the user is viewing this source code in. Do not replace the
  # escape sequence with a single literal character.
  # Do not change this! Do not make it '\u2b80'; that is the old, wrong code point.
  SEGMENT_SEPARATOR=$'\ue0b0'
}

prompt_segment() {

    echo -n "%{$bg[$1]%}%{$fg[$2]%}$3%{$reset_color%}"
}

prompt_color() {
  echo -n "%{$fg[$1]%}$2%{$reset_color%}"
}

prompt_bold_color() {
  echo -n "%{$fg_bold[$1]%}$2%{$reset_color%}"
}

prompt_prefix() {
  prompt_color green "╭─"
}

prompt_context() {
  if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    prompt_segment blue white "[${CONDA_DEFAULT_ENV:t:gs/%/%%}]"
    # prompt_color red "[${CONDA_DEFAULT_ENV:t:gs/%/%%}]"
  else
    prompt_segment green black "[${USERNAME:t:gs/%/%%}]"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
  local git_prompt

  if [[ "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
    local repo_path=$(command git rev-parse --show-toplevel 2>/dev/null)
    local dirty=$(parse_git_dirty)
    local ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref="◈ $(command git describe --exact-match --tags HEAD 2> /dev/null)" || \
    ref="➦ $(command git rev-parse --short HEAD 2> /dev/null)"
  
    local branch_status color repository_name branch_name remote_name
    if [[ -n $dirty ]]; then
      color=magenta
      branch_status="%{$fg[red]%}✘%{$fg[$color]%}"
    else
      color=cyan
      branch_status="%{$fg[green]%}✔%{$fg[$color]%}"
    fi
    repository_name=$(basename "$repo_path")
    branch_name=${ref#refs/heads/}
    remote_name=$(command git config --get branch.${branch_name}.remote)
    local behind ahead

    behind=$(git rev-list --count ${branch_name}..${remote_name}/${branch_name} 2>/dev/null)
    ahead=$(git rev-list --count ${remote_name}/${branch_name}..${branch_name} 2>/dev/null)

    local ahead_behind_info=""
    if [[ $ahead -gt 0 ]]; then
      ahead_behind_info="%{$fg[green]%}+${ahead}%{$fg[$color]%} "
    fi
    if [[ $behind -gt 0 ]]; then
      ahead_behind_info=" ${ahead_behind_info}%{$fg[red]%}-${behind}%{$fg[$color]%} "
    fi

    git_prompt="${branch_status} ${repository_name} ( ${remote_name}/${branch_name} ${ahead_behind_info})"
    prompt_bold_color $color "${git_prompt}"
    # echo -n " ${git_prompt}"
  fi
}

# Dir: current working directory
prompt_dir() {
  local current_dir=$(basename "$PWD")
  prompt_color yellow "[${current_dir}]"
  # prompt_segment yellow black " ${current_dir:t:gs/%/%%}"
}

prompt_time() {
  # prompt_segment white black "%D{%H:%M:%S}"
  prompt_bold_color white " %D{%H:%M:%S} "
}


# Newline
prompt_newline() {
  echo ''
  local current_dir=$(basename "$PWD")
  prompt_color green "╰─[${current_dir}]$"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_prefix
  prompt_context
  prompt_time
  prompt_git
  prompt_newline
}

PROMPT='%{%f%b%k%}$(build_prompt) '
