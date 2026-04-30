if status is-interactive
# Commands to run in interactive sessions can go here
end
    
function fish_greeting
end

set -gx PATH $PATH ~/.config/emacs/bin ~/.local/bin
alias vim="nvim"
alias ssh="TERM=xterm-256color command ssh"
alias rebuild="sudo nixos-rebuild switch --impure --flake /home/cier/nixos-config"
