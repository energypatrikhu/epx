alias fs.freeze='chattr +a'
alias fs.unfreeze='chattr -a'

alias fs.lock='chattr +i'
alias fs.unlock='chattr -i'

alias fs.bak='fs.archive'
alias fs.unbak='fs.unarchive'

alias fs.rm='rm -rfvI'
alias fs.cp='cp -rfvi --update=all'
alias fs.copy='cp -rfvi --update=all'
alias fs.mv='mv -fvi --update=all'
alias fs.move='mv -fvi --update=all'

alias fs.own='chown -R'
alias fs.mod='chmod -R'

alias fs.size='du -sh'
