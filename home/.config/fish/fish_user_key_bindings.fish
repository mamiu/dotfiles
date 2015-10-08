function fish_user_key_bindings
    # fish_vi_key_bindings
    # bind -M insert \e\n accept-autosuggestion execute
    bind \e\n accept-autosuggestion execute
    bind \e\n accept-autosuggestion execute
    bind \ck history-search-backward
    bind \e\[I 'begin;end'
    bind \e\[O 'begin;end'
end
