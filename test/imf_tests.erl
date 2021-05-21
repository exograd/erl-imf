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

-module(imf_tests).

-include_lib("eunit/include/eunit.hrl").

quote_test_() ->
  [?_assertEqual(<<"hello">>,
                 imf:quote(<<"hello">>, atom)),
   ?_assertEqual(<<"\"hello\\\"world\"">>,
                 imf:quote(<<"hello\"world">>, atom)),
   ?_assertEqual(<<"\"hello world\"">>,
                 imf:quote(<<"hello world">>, atom)),
   ?_assertEqual(<<"\"hello\\nworld\"">>,
                 imf:quote(<<"hello\nworld">>, atom)),
   ?_assertEqual(<<"\"hello.world\"">>,
                 imf:quote(<<"hello.world">>, atom)),
   ?_assertEqual(<<"hello.world">>,
                 imf:quote(<<"hello.world">>, dotatom)),
   ?_assertEqual(<<"\"hello\\\\world\"">>,
                 imf:quote(<<"hello\\world">>, atom))].

encode(Mail) ->
  iolist_to_binary(imf:encode(Mail)).

encode_test_() ->
  [?_assertEqual(
      <<>>,
      encode(#{header => [], body => <<>>})),

   %% Date header field
   ?_assertEqual(
      <<"Date: Fri, 21 May 2021 14:47:17 +0200\r\n">>,
      encode(#{header =>
                 [{date,
                   {localtime, {{2021,5,21},{14,47,17}}}}],
               body => <<>>})),

