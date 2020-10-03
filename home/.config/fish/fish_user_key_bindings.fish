function fish_user_key_bindings
    bind \e\r accept-autosuggestion repaint execute
    bind \el 'commandline -a la; commandline -f execute'
    bind \ck history-search-backward
    bind \cJ fzf-cd-widget
    bind \ew 'commandline -b "watch -n 1 $history[1]"; commandline -f repaint; commandline -f execute'
    # temporary fix for a bug where strange characters are inserted when scrolling
    bind \e\[I 'begin;end'
    bind \e\[O 'begin;end'
end
