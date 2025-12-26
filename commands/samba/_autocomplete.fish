function __epx_fish_smb_users
  if command -q pdbedit
    pdbedit -L | cut -d: -f1
  end
end

complete -c smb.del -f -a '(__epx_fish_smb_users)'
