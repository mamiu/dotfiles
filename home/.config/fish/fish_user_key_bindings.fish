function fish_user_key_bindings
    bind \e\r accept-autosuggestion execute
    bind \el 'commandline -a la; commandline -f execute'
    bind \ck history-search-backward
    bind \e\[I 'begin;end'
    bind \e\[O 'begin;end'
end
