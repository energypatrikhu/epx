alias fs.freeze="$(which chattr) +a"
alias fs.unfreeze="$(which chattr) -a"

alias fs.lock="$(which chattr) +i"
alias fs.unlock="$(which chattr) -i"

alias fs.bak="fs.archive"
alias fs.unbak="fs.unarchive"

alias fs.rm="$(which rm) -rfvI"
alias fs.cp="$(which cp) -rfvi --update=all"
alias fs.copy="$(which cp) -rfvi --update=all"
alias fs.mv="$(which mv) -fvi --update=all"
alias fs.move="$(which mv) -fvi --update=all"

alias fs.own="$(which chown) -R"
alias fs.mod="$(which chmod) -R"

alias fs.size="$(which du) -sh"
