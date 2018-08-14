# change directory to local repository
alias g='cd $(ghq root)/$(ghq list | fzf)'
# open remote repository with browser
alias gh='hub browse $(ghq list | fzf | cut -d "/" -f 2,3)'
