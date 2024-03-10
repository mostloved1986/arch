# Скрыть приветствие
set -g fish_greeting

# Путь
if status --is-login
    set -gx PATH $PATH ~/linux/bin
end

# Starship
starship init fish | source

# Neofetch
neofetch

# Список каталогов
alias ls="lsd"
alias l="ls -l"
alias la="ls -a"
alias lla="ls -la"
alias lt="ls --tree"

# Удобные сочетания клавиш для смены каталогов
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .3 'cd ../../..'
abbr .4 'cd ../../../..'
abbr .5 'cd ../../../../..'

# Всегда mkdir путь (это не мешает созданию одного каталога)
abbr mkdir 'mkdir -p'
