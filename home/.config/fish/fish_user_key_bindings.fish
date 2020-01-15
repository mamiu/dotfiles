function fish_user_key_bindings
    # fish_vi_key_bindings
    #
    # swap the comment of the next two lines for old versions of fish

    #bind \r accept-autosuggestion execute
    bind \cs accept-autosuggestion execute
    bind \ck history-search-backward
    bind \e\[I 'begin;end'
    bind \e\[O 'begin;end'
end
