%% Copyright (c) 2021 Bryan Frimin <bryan@frimin.fr>.
%%
%% Permission to use, copy, modify, and/or distribute this software for any
%% purpose with or without fee is hereby granted, provided that the above
%% copyright notice and this permission notice appear in all copies.
%%
%% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
%% WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
%% MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
%% SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
%% WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
%% ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
%% IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

-module(imf_mime).

-export([qencode/1]).

-type encoding() :: ascii | latin1 | utf8.

-spec qencode(binary()) -> binary().
qencode(Bin) ->
  case heuristic_encoding_bin(Bin) of
    ascii ->
      imf:quote(Bin, atom); %% TODO: take care about dot atom
    utf8 ->
      qencode(Bin, utf8, fun string:length/1, fun string:slice/3, []);
    latin1 ->
      qencode(Bin, latin1, fun erlang:byte_size/1, fun binary:part/3, [])
  end.

-spec qencode(binary(), encoding(), term(), term(), iodata()) -> binary().
qencode(<<>>, _, _, _, Acc) ->
  iolist_to_binary(lists:join(" ", lists:reverse(Acc)));
qencode(Bin, Encoding, SizeF, SliceF, Acc) ->
  EncodingName = encoding_name(Encoding),
  {EncodedWord, Rest} =
    qencode_1(Bin, EncodingName, SizeF, SliceF),
  qencode(Rest, Encoding, SizeF, SliceF, [EncodedWord | Acc]).

-spec qencode_1(binary(), binary(), term(), term()) -> {iodata(), binary()}.
qencode_1(Bin, EncodingName, SizeF, SliceF) ->
  CurSize = 2 + byte_size(EncodingName) + 3 + 2,
  case CurSize + SizeF(Bin) of
    N when N =< 75 ->
      {["=?", EncodingName, "?Q?", qencode(Bin, []), "?="], <<>>};
    _ ->
      P1 = SliceF(Bin, 0, 75 - CurSize),
      P2 = SliceF(Bin, 75 - CurSize, SizeF(Bin) - (75 - CurSize)),
      {["=?", EncodingName, "?Q?", qencode(P1, []), "?="], P2}
  end.

-spec qencode(binary(), iodata()) -> iodata().
qencode(<<>>, Acc) ->
  lists:reverse(Acc);
qencode(<<C, Rest/binary>>, Acc) when C =:= $\s ->
  qencode(Rest, [$_ | Acc]);
qencode(<<C, Rest/binary>>, Acc) when C > $\s, C =< $~,
                                      C =/= $_,
                                      C =/= $=,
                                      C =/= $! ->
  qencode(Rest, [C | Acc]);
qencode(<<C, Rest/binary>>, Acc) ->
  qencode(Rest, [[$=, hex:encode(<<C>>, [uppercase])] | Acc]).

-spec encoding_name(encoding()) -> binary().
encoding_name(latin1) ->
  <<"ISO-8859-1">>;
encoding_name(utf8) ->
  <<"UTF-8">>.

-spec heuristic_encoding_bin(binary()) -> encoding().
heuristic_encoding_bin(Bin) ->
  case is_ascii(Bin) of
    true ->
      ascii;
    false ->
      case unicode:characters_to_binary(Bin, utf8, utf8) of
        Bin -> utf8;
        _ -> latin1
      end
  end.

-spec is_ascii(binary()) -> boolean().
is_ascii(<<>>) -> true;
is_ascii(<<C, Rest/binary>>) when C >= 0, C =< 127 ->
  is_ascii(Rest);
is_ascii(_) ->
  false.