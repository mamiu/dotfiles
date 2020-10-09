function fish_user_key_bindings
    bind \e\r accept-autosuggestion repaint execute
    bind \el 'commandline -a la; commandline -f execute'
    bind \ck history-search-backward
    bind \cJ fzf-cd-widget
    bind \ew 'commandline -b "watch -n 1 $history[1]"; commandline -f repaint; commandline -f execute'
    bind \es 'commandline -b "sudo $history[1]"; commandline -f repaint; commandline -f execute'
end
