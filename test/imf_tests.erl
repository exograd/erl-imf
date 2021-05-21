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

   %% From header field
   ?_assertEqual(
      <<"From: JohnDoe <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{from,
                   [{mailbox,
                     #{name => <<"JohnDoe">>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: \"John Doe\" <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{from,
                   [{mailbox,
                     #{name => <<"John Doe">>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: john.doe@example.com\r\n">>,
      encode(#{header =>
                 [{from,
                   [{mailbox,
                     #{address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: =?ISO-8859-1?Q?John_Do=E9?= <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{from,
                   [{mailbox,
                     #{name => <<"John Doé">>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: =?UTF-8?Q?John_Do=C3=A9?= <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{from,
                   [{mailbox,
                     #{name => <<"John Doé"/utf8>>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: Group1:;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group, #{name => <<"Group1">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: \"Group 1\":;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group, #{name => <<"Group 1">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group, #{name => <<"Group d'été">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: =?UTF-8?Q?Group_d'=C3=A9t=C3=A9?=:;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group, #{name => <<"Group d'été"/utf8>>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: Group1:\"John Doe\" <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group,
                     #{name => <<"Group1">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doe">>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: Group1:=?ISO-8859-1?Q?John_Do=E9?= <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group,
                     #{name => <<"Group1">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doé">>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: Group1:=?UTF-8?Q?John_Do=C3=A9?= <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group,
                     #{name => <<"Group1">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doé"/utf8>>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:=?UTF-8?Q?John_Do=C3=A9?= <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group,
                     #{name => <<"Group d'été">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doé"/utf8>>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:john.doe@example.com;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group,
                     #{name => <<"Group d'été">>,
                       addresses =>
                         [{mailbox,
                           #{address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:john.doe@example.com,\r\n Person1 <person1@example.com>;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group,
                     #{name => <<"Group d'été">>,
                       addresses =>
                         [{mailbox,
                           #{address => <<"john.doe@example.com">>}},
                          {mailbox,
                           #{name => <<"Person1">>,
                             address => <<"person1@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: =?UTF-8?Q?Group_d'=C3=A9t=C3=A9?=:john.doe@example.com,\r\n \"Person.1\" <person1@example.com>;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group,
                     #{name => <<"Group d'été"/utf8>>,
                       addresses =>
                         [{mailbox,
                           #{address => <<"john.doe@example.com">>}},
                          {mailbox,
                           #{name => <<"Person.1">>,
                             address => <<"person1@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: person1@example.com,\r\n person2@example.com,\r\n person3@example.com\r\n">>,
      encode(#{header =>
                 [{from,
                   [{mailbox, #{address => <<"person1@example.com">>}},
                    {mailbox, #{address => <<"person2@example.com">>}},
                    {mailbox, #{address => <<"person3@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: \"Person 1\" <person1@example.com>,\r\n \"Group 1\":;,\r\n \"Person 2\" <person2@example.com>,\r\n person3@example.com\r\n">>,
      encode(#{header =>
                 [{from,
                   [{mailbox,
                     #{name => <<"Person 1">>,
                       address => <<"person1@example.com">>}},
                    {group,
                     #{name => <<"Group 1">>}},
                    {mailbox,
                     #{name => <<"Person 2">>,
                       address => <<"person2@example.com">>}},
                    {mailbox,
                     #{address => <<"person3@example.com">>}}]}],
               body => <<>>})),
