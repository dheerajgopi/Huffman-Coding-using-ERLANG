-module(huffman).
-export([build_tree/1, trimtree/1, assign_codes/1, encode/1, decode/2, show_example/1]).

frequency(Text) ->
    lists:foldl(fun(X,[{[X],I}|Q]) ->
        [{[X],I+1}|Q] ; (X,Acc) -> [{[X],1}|Acc] end ,
            [],
            Text).

sort_frequency(Text) ->
    Freq_list = frequency(Text),
    lists:keysort(2, lists:keysort(1, Freq_list)).

build_tree(Text) ->
    Sorted_freq_list = sort_frequency(Text),
    build_tree_helper(Sorted_freq_list).

build_tree_helper([{X,I},{Y,J}|[]]) ->
    {{{X,I},{Y,J}}, I+J};

build_tree_helper([{X,I},{Y,J}|Rest]) ->
    Combined_freq = {{{X,I},{Y,J}}, I+J},
    New_list = lists:keysort(2, [Combined_freq|Rest]),
    build_tree_helper(New_list).

trimtree({Inner_tree, _Freq}) when is_list(Inner_tree) ->
    Inner_tree;

trimtree({{Inner_treeL,Inner_treeR }, _Freq}) ->
    {trimtree(Inner_treeL), trimtree(Inner_treeR)}.

assign_codes({TrimtreeL, TrimtreeR}) ->
    Codes = 
        [assign_codes_helper(TrimtreeL, "0")]
        ++ 
        [assign_codes_helper(TrimtreeR, "1")],
    lists:flatten(Codes).

assign_codes_helper(Trimmed_tree, Codelist) when is_list(Trimmed_tree) ->
    {Trimmed_tree, Codelist};

assign_codes_helper({TreeL,TreeR}, Codelist) ->
    [assign_codes_helper(TreeL, Codelist++"0")]
    ++
    [assign_codes_helper(TreeR, Codelist++"1")].

encode(Text) ->
    Tree = build_tree(Text),
    Trimmed_tree = trimtree(Tree),
    Codes = dict:from_list(assign_codes(Trimmed_tree)),
    encode_helper(Text, "", Codes).

encode_helper([Letter|[]], Encoded_text, Code) ->
    {ok, Enc_letter} = dict:find([Letter], Code),
    Encoded_text ++ Enc_letter;
   
encode_helper([Letter|Rest], Encoded_text, Code) ->
    {ok, Enc_letter} = dict:find([Letter], Code),
    encode_helper(Rest, Encoded_text ++ Enc_letter, Code).

decode(Enc_text, Tree) ->
    decode_helper(Enc_text, "", Tree, Tree).

decode_helper([Bit|[]], Original, {TreeL, TreeR}, _Orig_tree) ->
    case Bit of
        $0 ->
            Original ++ TreeL;
        $1 ->
            Original ++ TreeR
    end;

decode_helper([Bit|Rest], Original, {TreeL, TreeR}, Orig_tree) ->
    case Bit of
        $0 when is_list(TreeL) ->
            decode_helper(Rest, Original++TreeL, Orig_tree, Orig_tree);
 
        $0 when is_tuple(TreeL) ->
            decode_helper(Rest, Original, TreeL, Orig_tree);

        $1 when is_list(TreeR) ->
            decode_helper(Rest, Original++TreeR, Orig_tree, Orig_tree);

        $1 when is_tuple(TreeR) ->
            decode_helper(Rest, Original, TreeR, Orig_tree)
    end.

show_example(Text) ->
    io:fwrite("\nInput string -----> \n"),
    io:fwrite(Text),
    io:fwrite("\n====================\n"),
    A = build_tree(Text),
    B = trimtree(A),
    C = encode(Text),
    io:fwrite("\nEncoded string -----> \n"),
    io:fwrite(C),
    io:fwrite("\n====================\n"),
    io:fwrite("\nDecoded string -----> \n"),
    decode(C, B).
